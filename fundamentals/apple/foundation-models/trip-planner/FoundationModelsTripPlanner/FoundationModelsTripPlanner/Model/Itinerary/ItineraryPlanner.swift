/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that generates an itinerary by streaming the response output in its partially generated form.
*/

import Foundation
import FoundationModels
import Observation
import FirebaseAILogic
import FirebaseAI
import UIKit

@Observable
@MainActor
final class ItineraryPlanner {
    private(set) var itinerary: Itinerary.PartiallyGenerated?
    private(set) var pointOfInterestTool: FindPointsOfInterestMapsTool
    private var session: LanguageModelSession
    private(set) var selectedLandmarks: [String] = []
    private(set) var customSpotImages: [String: UIImage] = [:]
    
    var error: Error?
    let landmark: Landmark
    var isRequested: Bool = false
  
    init(landmark: Landmark) {
        self.landmark = landmark
        Logging.general.log("The landmark is... \(landmark.name)")
        let pointOfInterestTool = FindPointsOfInterestMapsTool(landmark: landmark)
        
        let model = FirebaseAI.firebaseAI().geminiLanguageModel(
            name: "gemini-3.1-flash-lite"
        )
        
        self.session = LanguageModelSession(
            model: model,
            tools: [pointOfInterestTool],
            instructions: Instructions {
                "Your job is to create an itinerary for the person."
                
                "Each day needs an activity, hotel and restaurant."
                
                """
                Always use the findPointsOfInterestMaps tool to find businesses \
                and activities in \(landmark.name), especially hotels \
                and restaurants.
                
                The point of interest categories may include:
                """
                FindPointsOfInterestMapsTool.Category.allCases.map { $0.rawValue }.joined(separator: ", ")
                
                """
                Here is a description of \(landmark.name) for your reference \
                when considering what activities to generate:
                """
                landmark.description
            }
        )
        self.pointOfInterestTool = pointOfInterestTool
    }

    func suggestItinerary(dayCount: Int) async throws {
        isRequested = true
        let landmarkName = self.landmark.name
        let landmarksToVisit = self.selectedLandmarks
        
        Logging.general.log("suggestItinerary started for dayCount: \(dayCount), landmarkName: \(landmarkName)")
        
        do {
            let stream = session.streamResponse(
                generating: Itinerary.self,
                options: GenerationOptions(samplingMode: .greedy),
                contextOptions: ContextOptions(reasoningLevel: .light)
            ) {
                "Generate a \(dayCount)-day itinerary to \(landmarkName)."
                
                "Give it a fun title and description."
                
                landmarksToVisit.isEmpty ? "" : "The user has explicitly requested to visit the following landmarks:"
                landmarksToVisit.joined(separator: ", ")
                landmarksToVisit.isEmpty ? "" : "Please ensure these landmarks are included in the itinerary on appropriate days."
                
                "Here is an example, but don't copy it:"
                String(describing: Itinerary.exampleTripToJapan)
            }

            for try await partialResponse in stream {
                itinerary = partialResponse.content
                let currentContent = partialResponse.content
                Logging.general.log("suggestItinerary: received chunk, current title is: \(currentContent.title ?? "nil")")
            }
            Logging.general.log("suggestItinerary successfully completed!")
        } catch {
            Logging.general.error("suggestItinerary failed with error: \(error.localizedDescription) - full description: \(String(describing: error))")
            throw error
        }
    }
    
    func updateItinerary(with newLandmark: String, image: UIImage? = nil) async throws {
        guard let currentItinerary = itinerary else { return }
        
        Logging.general.log("updateItinerary started for newLandmark: \(newLandmark)")
        if let image = image {
            customSpotImages[newLandmark] = image
        }
        
        do {
            let stream = session.streamResponse(
                generating: Itinerary.self,
                options: GenerationOptions(samplingMode: .greedy),
                contextOptions: ContextOptions(reasoningLevel: .light)
            ) {
                "Here is the current itinerary:"
                String(describing: currentItinerary)
                
                "The user has just visited and identified a new landmark: \(newLandmark)."
                "Please select the best day in the itinerary to include this landmark."
                "Regenerate ONLY that specific day to include the new landmark. Do not change any other days."
                "Return the full itinerary with the updated day, keeping everything else identical."
            }

            for try await partialResponse in stream {
                itinerary = partialResponse.content
                let currentContent = partialResponse.content
                Logging.general.log("updateItinerary: received chunk, current title is: \(currentContent.title ?? "nil")")
            }
            Logging.general.log("updateItinerary successfully completed!")
        } catch {
            Logging.general.error("updateItinerary failed with error: \(error.localizedDescription) - full description: \(String(describing: error))")
            throw error
        }
    }

    func addSelectedLandmark(_ name: String, image: UIImage? = nil) {
        if !selectedLandmarks.contains(name) {
            selectedLandmarks.append(name)
            if let image = image {
                customSpotImages[name] = image
            }
        }
    }
    
    func removeSelectedLandmark(_ name: String) {
        selectedLandmarks.removeAll { $0 == name }
    }

    func applyLiveModification(dayNumber: Int, action: String, activityIndex: Int?, categoryStr: String?, title: String?, description: String?) {
        guard var current = itinerary else { return }
        guard var days = current.days else { return }
        
        let dayIdx = dayNumber - 1
        guard dayIdx >= 0 && dayIdx < days.count else { return }
        var day = days[dayIdx]
        var activities = day.activities ?? []
        
        let category: Kind? = categoryStr.flatMap { Kind(rawValue: $0) }
        
        switch action {
        case "add":
            guard let emptyContent = try? FirebaseAI.GeneratedContent(json: "{}"),
                  var newActivity = try? Activity.PartiallyGenerated(emptyContent) else { return }
            newActivity.type = category
            newActivity.title = title
            newActivity.description = description
            activities.append(newActivity)
            
        case "replace":
            guard let actIdx = activityIndex, actIdx >= 0 && actIdx < activities.count else { return }
            var updatedActivity = activities[actIdx]
            if let category {
                updatedActivity.type = category
            }
            if let title {
                updatedActivity.title = title
            }
            if let description {
                updatedActivity.description = description
            }
            activities[actIdx] = updatedActivity
            
        case "remove":
            guard let actIdx = activityIndex, actIdx >= 0 && actIdx < activities.count else { return }
            activities.remove(at: actIdx)
            
        default:
            return
        }
        
        day.activities = activities
        days[dayIdx] = day
        current.days = days
        self.itinerary = current
    }

    func prewarm() {
        session.prewarm()
    }
}

extension Itinerary {
    static let exampleTripToJapan = Itinerary(
        title: "Onsen Trip to Japan",
        destinationName: "Mt. Fuji",
        description: "Sushi, hot springs, and ryokan with a toddler!",
        rationale:
            """
            You are traveling with a child, so climbing Mt. Fuji is probably not an option, \
            but there is lots to do around Kawaguchiko Lake, including Fujikyu. \
            I recommend staying in a ryokan because you love hotsprings.
            """,
        days: [
            DayPlan(
                title: "Sushi and Shopping Near Kawaguchiko",
                subtitle: "Spend your final day enjoying sushi and souvenir shopping.",
                destination: "Kawaguchiko Lake",
                activities: [
                    Activity(
                        type: .foodAndDining,
                        title: "The Restaurant serving Sushi",
                        description: "Visit an authentic sushi restaurant for lunch.",
                        latitude: nil,
                        longitude: nil
                    ),
                    Activity(
                        type: .shopping,
                        title: "The Plaza",
                        description: "Enjoy souvenir shopping at various shops.",
                        latitude: nil,
                        longitude: nil
                    ),
                    Activity(
                        type: .sightseeing,
                        title: "The Beautiful Cherry Blossom Park",
                        description: "Admire the beautiful cherry blossom trees in the park.",
                        latitude: nil,
                        longitude: nil
                    ),
                    Activity(
                        type: .hotelAndLodging,
                        title: "The Hotel",
                        description:
                            "Spend one final evening in the hotspring before heading home.",
                        latitude: nil,
                        longitude: nil
                    )
                ]
            )
        ]
    )
}
