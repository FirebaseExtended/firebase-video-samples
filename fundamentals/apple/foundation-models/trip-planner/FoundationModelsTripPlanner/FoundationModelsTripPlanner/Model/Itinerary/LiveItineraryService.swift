import Foundation
import SwiftUI
import FirebaseAILogic
import FirebaseCore

@MainActor
@Observable
final class LiveItineraryService {
    // MARK: - Dependencies
    private let mediaManager = LiveItineraryMediaManager()
    
    // MARK: - Session State
    private var liveSession: LiveSession?
    private var connectionId = UUID()
    
    var state: ConnectionState = .disconnected
    var currentSpeaker: SpeakerState = .idle
    var messages: [TranscriptMessage] = []
    
    // MARK: - User Controls
    var isMicrophoneMuted = false
    var isPaused = false
    
    // MARK: - Context
    let landmark: Landmark
    let itinerary: Itinerary.PartiallyGenerated
    let onModifyItinerary: (Int, String, Int?, String?, String?, String?) -> Void
    
    init(landmark: Landmark, itinerary: Itinerary.PartiallyGenerated, onModifyItinerary: @escaping (Int, String, Int?, String?, String?, String?) -> Void) {
        self.landmark = landmark
        self.itinerary = itinerary
        self.onModifyItinerary = onModifyItinerary
    }
    
    // MARK: - Public API
    
    func connect() async {
        guard await prepareForConnection() else { return }
        
        let currentId = UUID()
        self.connectionId = currentId
        resetLocalState()
        
        do {
            try await checkFirebaseConfiguration(currentId: currentId)
            
            // 1. Build Persona and Initialize Session
            let persona = buildSystemPersona()
            let session = try await initializeLiveSession(persona: persona)
            
            guard self.connectionId == currentId else {
                Task { await session.close() }
                return
            }
            
            self.liveSession = session
            
            // 2. Start Hardware
            try await mediaManager.startRecording(to: session, isMuted: isMicrophoneMuted, isPaused: isPaused, currentSpeaker: currentSpeaker) { [weak self] isUserSpeaking in
                self?.updateSpeakerState(isUserSpeaking: isUserSpeaking)
            }
            
            guard self.connectionId == currentId else { return }
            
            // 3. Handshake and Processing
            state = .connected
            await sendInitialGreeting(session: session)
            try await startProcessingResponses()
            
        } catch {
            handleConnectionError(error, currentId: currentId)
        }
    }
    
    func disconnect() async {
        self.connectionId = UUID()
        guard state != .disconnected && state != .disconnecting else { return }
        
        state = .disconnecting
        await mediaManager.stop()
        
        let oldSession = self.liveSession
        self.liveSession = nil
        Task { await oldSession?.close() }
        
        self.state = .disconnected
        self.currentSpeaker = .idle
    }
    
    func toggleMicrophone() {
        self.isMicrophoneMuted.toggle()
    }
    
    func togglePause() {
        self.isPaused.toggle()
    }
    
    func startVideoStreaming(from cameraManager: CameraManager) {
        guard let liveSession else { return }
        mediaManager.startVideoStreaming(from: cameraManager, session: liveSession, isPaused: isPaused)
    }
    
    func stopVideoStreaming(from cameraManager: CameraManager) {
        mediaManager.stopVideoStreaming(from: cameraManager)
    }
    
    // MARK: - Private Logic
    
    private func prepareForConnection() async -> Bool {
        switch state {
        case .disconnected, .error:
            state = .connecting
            return true
        default:
            return false
        }
    }
    
    private func resetLocalState() {
        messages.removeAll()
        currentSpeaker = .idle
    }
    
    private func checkFirebaseConfiguration(currentId: UUID) async throws {
        if FirebaseApp.app() == nil {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            guard self.connectionId == currentId else { throw ApplicationError("Cancelled") }
            throw ApplicationError("Firebase missing GoogleService-Info.plist")
        }
    }
    
    private func buildSystemPersona() -> String {
        var persona = """
        You are a friendly and knowledgeable tour guide for the landmark: \(landmark.name) located in \(landmark.continent).
        Here is the user's current day-by-day itinerary:

        Title: \(itinerary.title ?? "")
        Description: \(itinerary.description ?? "")

        Details:
        \((itinerary.days ?? []).enumerated().map { index, day in
            "Day \(index + 1) - \(day.title ?? ""): \(day.subtitle ?? "") (Destination: \(day.destination ?? ""))\nActivities:\n" + (day.activities ?? []).map { "- \($0.title ?? "") (\($0.type?.rawValue ?? "")): \($0.description ?? "")" }.joined(separator: "\n")
        }.joined(separator: "\n\n"))

        The user is currently viewing this itinerary and wants to ask you questions, modify the itinerary, get local recommendations, or discuss their plans. 
        Your response style must be helpful, encouraging, and natural for real-time speech dialogue. 
        Keep your spoken responses relatively concise, direct, and conversational.
        """

        if landmark.name == "Bengaluru" {
            persona += """

            Please use an Indian accent that is typical for the region of Bengaluru.
            When the user turns on the video feature and points the camera at a group of people or a crowd, you must respond enthusiastically. 
            Say something like "oh wow this is a fantastic crowd, what a massive number of people are here" or something along those lines.
            IMPORTANT: You must first say this response in Hindi or Kannada, and then say in English "this was Hindi for [the English translation]" (or Kannada) and then provide the English translation.
            """
        } else {
            persona += """
             Please use an australian accent when talking to the user and use everyday aussie slang like 'no worries at all mate'.
            """
        }

        return persona
    }
    
    private func initializeLiveSession(persona: String) async throws -> LiveSession {
        let ai = FirebaseAI.firebaseAI(backend: .vertexAI(location: "us-central1"))
        
        let modifyItineraryTool = Tool.functionDeclarations([
            FunctionDeclaration(
                name: "modifyItinerary",
                description: "Modifies the user's itinerary by adding, replacing, or removing an activity on a specific day.",
                parameters: [
                    "dayNumber": Schema.integer(
                        description: "The 1-based day number of the itinerary (e.g. 1 for Day 1, 2 for Day 2)."
                    ),
                    "action": Schema.string(
                        description: "The action to perform: 'add', 'replace', or 'remove'."
                    ),
                    "activityIndex": Schema.integer(
                        description: "The index (0-based) of the activity to replace or remove. Ignored for 'add'."
                    ),
                    "category": Schema.string(
                        description: "The category type of the activity: 'sightseeing', 'foodAndDining', 'shopping', 'hotelAndLodging'."
                    ),
                    "title": Schema.string(
                        description: "The title of the activity."
                    ),
                    "description": Schema.string(
                        description: "A description of the activity."
                    )
                ],
                optionalParameters: ["activityIndex", "category", "title", "description"]
            )
        ])
        
        let liveModel = ai.liveModel(
            modelName: "gemini-live-2.5-flash-native-audio",
            generationConfig: LiveGenerationConfig(
                responseModalities: [.audio],
                speech: SpeechConfig(voiceName: "Puck"),
                inputAudioTranscription: AudioTranscriptionConfig(),
                outputAudioTranscription: AudioTranscriptionConfig()
            ),
            tools: [modifyItineraryTool],
            systemInstruction: ModelContent(role: "system", parts: persona)
        )
        return try await liveModel.connect()
    }
    
    private func sendInitialGreeting(session: LiveSession) async {
        let greetingPrompt = "Hello! I am your tour guide for \(landmark.name). I have your itinerary here, and I can answer any questions you have about it or help you customize it. How can I help you today?"
        await session.sendContent(greetingPrompt, turnComplete: true)
    }
    
    private func startProcessingResponses() async throws {
        guard let liveSession else { return }
        
        for try await response in liveSession.responses {
            switch response.payload {
            case .content(let content):
                await handleContentResponse(content)
            case .toolCall(let toolCall):
                await handleToolCall(toolCall, session: liveSession)
            default:
                break
            }
        }
    }
    
    private func handleToolCall(_ toolCall: LiveServerToolCall, session: LiveSession) async {
        guard let functionCalls = toolCall.functionCalls, let functionCall = functionCalls.first else { return }
        
        Logging.general.log("LiveItineraryService: received tool call: \(functionCall.name) with args: \(functionCall.args)")
        
        if functionCall.name == "modifyItinerary" {
            let dayNumber = functionCall.args["dayNumber"]?.asInt() ?? 1
            let action = functionCall.args["action"]?.asString() ?? ""
            let activityIndex = functionCall.args["activityIndex"]?.asInt()
            let categoryStr = functionCall.args["category"]?.asString()
            let title = functionCall.args["title"]?.asString()
            let description = functionCall.args["description"]?.asString()
            
            await MainActor.run {
                onModifyItinerary(dayNumber, action, activityIndex, categoryStr, title, description)
            }
            
            let responsePart = FunctionResponsePart(
                name: functionCall.name,
                response: ["result": .string("Success")],
                functionId: functionCall.functionId
            )
            
            await session.sendFunctionResponses([responsePart])
            Logging.general.log("LiveItineraryService: sent tool response for \(functionCall.name)")
        }
    }
    
    private func handleContentResponse(_ content: LiveServerContent) async {
        if let message = content.modelTurn {
            currentSpeaker = .ai
            for part in message.parts {
                if let inlineData = part as? InlineDataPart, inlineData.mimeType.starts(with: "audio/pcm") {
                    await mediaManager.playAudio(inlineData.data)
                }
            }
        }
        
        if content.isTurnComplete || content.wasInterrupted {
            if currentSpeaker == .ai { currentSpeaker = .idle }
        }
        
        if let userTx = content.inputAudioTranscription?.text {
            appendMessage(text: userTx, isUser: true)
        }
        
        if let aiTx = content.outputAudioTranscription?.text {
            appendMessage(text: aiTx, isUser: false)
        }
    }
    
    private func updateSpeakerState(isUserSpeaking: Bool) {
        if isUserSpeaking {
            if self.currentSpeaker != .ai { self.currentSpeaker = .user }
        } else {
            if self.currentSpeaker == .user {
                self.currentSpeaker = .idle
            }
        }
    }
    
    private func appendMessage(text: String, isUser: Bool) {
        if var last = messages.last, last.isUser == isUser {
            last.text += text
            messages[messages.count - 1] = last
        } else {
            messages.append(TranscriptMessage(text: text, isUser: isUser))
        }
    }
    
    private func handleConnectionError(_ error: Error, currentId: UUID) {
        guard self.connectionId == currentId else { return }
        print("Live API Connection Error: \(error)")
        state = .error(error.localizedDescription)
        self.liveSession = nil
    }
}

private extension JSONValue {
    func asString() -> String? {
        if case .string(let val) = self {
            return val
        }
        return nil
    }
    
    func asInt() -> Int? {
        if case .number(let val) = self {
            return Int(val)
        }
        return nil
    }
}
