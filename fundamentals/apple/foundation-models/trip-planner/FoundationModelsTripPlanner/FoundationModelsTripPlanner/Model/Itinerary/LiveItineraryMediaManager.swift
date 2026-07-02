import Foundation
import FirebaseAILogic
import AVFoundation
import UIKit

@MainActor
final class LiveItineraryMediaManager {
    private var audioManager: AudioManager?
    private var microphoneTask = Task<Void, Never> {}
    private var videoFrameTimer: Timer?
    private var isSendingVideo = false
    
    // MARK: - Audio
    
    func startRecording(to session: LiveSession, 
                        isMuted: @escaping @MainActor () -> Bool, 
                        isPaused: @escaping @MainActor () -> Bool, 
                        currentSpeaker: @escaping @MainActor () -> SpeakerState, 
                        onSpeakerUpdate: @escaping @MainActor (Bool) -> Void) async throws {
        audioManager = AudioManager()
        guard let audioManager else { return }
        
        let stream = try await audioManager.listenToMic()
        microphoneTask = Task {
            for await (pcmData, rms) in stream {
                await processAudioBuffer(pcmData: pcmData, 
                                         rms: rms, 
                                         session: session, 
                                         isMuted: isMuted, 
                                         isPaused: isPaused, 
                                         currentSpeaker: currentSpeaker, 
                                         onSpeakerUpdate: onSpeakerUpdate)
            }
        }
    }
    
    private func processAudioBuffer(pcmData: Data, 
                                    rms: Float, 
                                    session: LiveSession, 
                                    isMuted: @escaping @MainActor () -> Bool, 
                                    isPaused: @escaping @MainActor () -> Bool, 
                                    currentSpeaker: @escaping @MainActor () -> SpeakerState, 
                                    onSpeakerUpdate: @escaping @MainActor (Bool) -> Void) async {
        let muted = isMuted()
        let paused = isPaused()
        let speaker = currentSpeaker()
        
        let shouldSendAudio = !muted && !paused
        guard shouldSendAudio else { return }
        
        // Barge-in prevention: If the AI is speaking, we don't want to send user audio
        // even if the RMS is above the threshold.
        let isAISpeaking = speaker == .ai
        
        let noiseGateThreshold: Float = isAISpeaking ? 0.08 : 0.015
        let isUserSpeaking = !isAISpeaking && rms > noiseGateThreshold
        
        if isUserSpeaking {
            await session.sendAudioRealtime(pcmData)
        } else if !isAISpeaking {
            let silence = Data(count: pcmData.count)
            await session.sendAudioRealtime(silence)
        }
        
        onSpeakerUpdate(isUserSpeaking)
    }
    
    func playAudio(_ data: Data) async {
        await audioManager?.playAudio(audio: data)
    }
    
    // MARK: - Video
    
    func startVideoStreaming(from cameraManager: CameraManager, session: LiveSession, isPaused: @escaping @MainActor () -> Bool) {
        isSendingVideo = true
        cameraManager.startVideoDataOutput()
        
        // Send the very first frame immediately
        sendVideoFrame(from: cameraManager, session: session, isPaused: isPaused)
        
        videoFrameTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.sendVideoFrame(from: cameraManager, session: session, isPaused: isPaused)
        }
    }
    
    private func sendVideoFrame(from cameraManager: CameraManager, session: LiveSession, isPaused: @escaping @MainActor () -> Bool) {
        Task { @MainActor in
            let paused = isPaused()
            guard self.isSendingVideo, !paused else { return }
            
            if let image = await cameraManager.getLatestVideoFrame(),
               let jpegData = image.jpegData(compressionQuality: 0.4) {
                await session.sendVideoRealtime(jpegData, mimeType: "image/jpeg")
            }
        }
    }
    
    func stopVideoStreaming(from cameraManager: CameraManager) {
        isSendingVideo = false
        videoFrameTimer?.invalidate()
        videoFrameTimer = nil
        cameraManager.stopVideoDataOutput()
    }
    
    // MARK: - Cleanup
    
    func stop() async {
        videoFrameTimer?.invalidate()
        videoFrameTimer = nil
        isSendingVideo = false
        
        await audioManager?.stop()
        microphoneTask.cancel()
        audioManager = nil
    }
}
