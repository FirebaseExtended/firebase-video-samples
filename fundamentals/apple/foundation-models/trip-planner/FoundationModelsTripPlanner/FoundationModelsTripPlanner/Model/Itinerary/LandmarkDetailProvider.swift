/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A provider to fetch detailed information about a landmark activity.
*/

import Foundation
import FoundationModels
import Observation
import UIKit

@Generable
struct OpeningHour: Codable, Hashable {
    @Guide(description: "The days of the week, e.g., 'Monday - Friday' or 'Daily'.")
    let days: String
    @Guide(description: "The hours of operation, e.g., '9:00 AM - 5:00 PM' or 'Closed'.")
    let hours: String
}

@Generable
struct LandmarkDetailResponse: Codable {
    @Guide(description: "A detailed summary of what you can do at the place.")
    let description: String
    @Guide(description: "A list of strings containing general information details like address, phone, and fees.")
    let generalInfo: [String]?
    @Guide(description: "A list of opening hours.")
    let openingTimes: [OpeningHour]?
    @Guide(description: "A list of strings containing events currently on for the upcoming week.")
    let upcomingEvents: [String]?
}

import FirebaseAILogic

@Observable
@MainActor
final class LandmarkDetailProvider {
    private(set) var detailInfo: LandmarkDetailResponse.PartiallyGenerated?
    private(set) var groundingMetadata: GroundingMetadata?
    private(set) var unsplashImageUrl: String?
    private var session: LanguageModelSession
    private let unsplashService = UnsplashService()
    
    var error: Error?
    let activityTitle: String
    let landmarkName: String

    init(activityTitle: String, landmarkName: String) {
        self.activityTitle = activityTitle
        self.landmarkName = landmarkName
        
        let model = FirebaseAI.firebaseAI().geminiLanguageModel(
            name: "gemini-3.1-flash-lite",
            serverTools: [.googleSearch()]
        )
        self.session = LanguageModelSession(
            model: model,
            instructions:
                """
                Provide a detailed description, general information, opening hours, 
                and upcoming events for the requested place.
                Use Google Search to find the most up-to-date information.
                """
        )
    }

    func fetchDetails() async throws {
    let stream = session.streamResponse(
        generating: LandmarkDetailResponse.self,
        includeSchemaInPrompt: true,
        options: GenerationOptions(samplingMode: .greedy)
    ) {
        """
        Provide a detailed description, general information, opening hours, and upcoming events for \(self.activityTitle) in \(self.landmarkName).
        Use Google Search to find the most up-to-date information. Be sure to check if the place is a public landmark or viewing platform, and prioritize its public visiting hours over commercial office hours.
        """
    }
        
        do {
            for try await snapshot in stream {
                self.detailInfo = snapshot.content
            }
            
            // Extract grounding metadata from the session's transcript
            for entry in session.transcript {
                if case let .response(responseEntry) = entry {
                    if let metadata = responseEntry.metadata["groundingMetadata"] as? GroundingMetadata {
                        self.groundingMetadata = metadata
                    }
                }
            }
        } catch {
            self.error = error
            Logging.general.error("LandmarkDetailProvider error: \(error.localizedDescription)")
            throw error
        }
        
        // Fetch Unsplash image
        do {
            unsplashImageUrl = try await unsplashService.searchPhotos(query: "\(activityTitle) \(landmarkName)")
        } catch {
            Logging.general.error("Unsplash fetch error: \(error.localizedDescription)")
        }
    }
}
