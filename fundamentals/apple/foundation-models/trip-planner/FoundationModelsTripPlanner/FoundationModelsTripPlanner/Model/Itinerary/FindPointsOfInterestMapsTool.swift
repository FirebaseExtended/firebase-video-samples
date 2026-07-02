import FoundationModels
import SwiftUI
import FirebaseAILogic


@Observable
@MainActor
final class FindPointsOfInterestMapsTool: FoundationModels.Tool {
    typealias Output = String
    
    
    nonisolated static func == (lhs: FindPointsOfInterestMapsTool, rhs: FindPointsOfInterestMapsTool) -> Bool {
        lhs === rhs
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    nonisolated var name: String { "findPointsOfInterestMaps" }
    nonisolated var description: String { "Finds points of interest for a landmark using Google Maps." }
    
    let landmark: Landmark
    
    @MainActor var lookupHistory: [Lookup] = []
    
    init(landmark: Landmark) {
        self.landmark = landmark
    }

    @Generable
    enum Category: String, CaseIterable {
        case campground = "campgrounds"
        case hotel = "hotels"
        case cafe = "cafes"
        case museum = "museums"
        case marina = "marinas"
        case restaurant = "restaurants"
        case nationalMonument = "national monuments"
    }

    @Generable
    struct Arguments {
        @Guide(description: "This is the type of destination to look up for.")
        let pointOfInterest: Category

        @Guide(description: "The natural language query of what to search for.")
        let naturalLanguageQuery: String
    }
    
    struct Lookup: Identifiable, Hashable {
        let id = UUID()
        let history: Arguments
        var groundingMetadata: GroundingMetadata?
        
        static func == (lhs: Lookup, rhs: Lookup) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @MainActor func recordLookup(arguments: Arguments, metadata: GroundingMetadata? = nil) {
        lookupHistory.append(Lookup(history: arguments, groundingMetadata: metadata))
    }
    
    func call(arguments: Arguments) async throws -> String {
        let startTime = Date()
        Logging.general.log("FindPointsOfInterestMapsTool: call called with query: \(arguments.naturalLanguageQuery), category: \(arguments.pointOfInterest.rawValue)")
        
        let model = FirebaseAI.firebaseAI(backend: .vertexAI(location: "global"))
            .geminiLanguageModel(
                name: "gemini-3.1-flash-lite",
                serverTools: [.googleMaps()]
            )
        
        let session = LanguageModelSession(
            model: model,
            instructions: Instructions {
                "Find 3 real spots matching the category near the landmark."
            }
        )
        
        let prompt = """
        Find 3 real \(arguments.pointOfInterest.rawValue) near \(landmark.name) at coordinates (\(landmark.latitude), \(landmark.longitude)) based on this query: \(arguments.naturalLanguageQuery). Use Google Maps to find real places.
        List the 3 real spots as a simple list with one place per line. Do not write any introduction, numbering, markdown bold, or other text.
        """
        
        var results: [String] = []
        var realMetadata: GroundingMetadata? = nil
        var fullText = ""
        
        Logging.general.log("FindPointsOfInterestMapsTool: nested session started. Prompt:\n\(prompt)")
        
        do {
            let stream = session.streamResponse(
                options: GenerationOptions(samplingMode: .greedy),
                contextOptions: ContextOptions(reasoningLevel: .light)
            ) {
                prompt
            }
            
            for try await chunk in stream {
                fullText = chunk.content
                Logging.general.log("FindPointsOfInterestMapsTool: received text chunk: '\(chunk.content)'")
            }
            let duration = Date().timeIntervalSince(startTime)
            Logging.general.log("FindPointsOfInterestMapsTool: nested session completed in \(String(format: "%.2f", duration))s. Full text:\n\(fullText)")
            
            results = fullText.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { line in
                    if line.hasPrefix("- ") {
                        return String(line.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if line.hasPrefix("* ") {
                        return String(line.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    return line
                }
            Logging.general.log("FindPointsOfInterestMapsTool: parsed places: \(results)")
            
            for entry in session.transcript {
                if case let .response(responseEntry) = entry {
                    if let metadata = responseEntry.metadata["groundingMetadata"] as? GroundingMetadata {
                        realMetadata = metadata
                        Logging.general.log("FindPointsOfInterestMapsTool: successfully retrieved groundingMetadata with \(metadata.groundingChunks.count) chunks.")
                        for chunk in metadata.groundingChunks {
                            if let maps = chunk.maps {
                                Logging.general.log("FindPointsOfInterestMapsTool: Grounding Chunk - Title: \(maps.title ?? "nil"), URL: \(maps.url?.absoluteString ?? "nil"), PlaceID: \(maps.placeID ?? "nil")")
                            }
                        }
                    }
                }
            }
            
            await recordLookup(arguments: arguments, metadata: realMetadata)
            
            let summaryResult = "There are these \(arguments.pointOfInterest.rawValue) in \(landmark.name): \(results.joined(separator: ", "))"
            Logging.general.log("FindPointsOfInterestMapsTool: returning summary: '\(summaryResult)'")
            return summaryResult
        } catch {
            Logging.general.error("FindPointsOfInterestMapsTool error: \(error.localizedDescription) - full description: \(String(describing: error))")
            throw error
        }
    }
}


