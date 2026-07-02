// xcode: set sdk=iOS

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A tool to use alongside the models to find points of interest for a landmark.
*/

import FoundationModels
import SwiftUI

@Observable
final class FindPointsOfInterestTool: Tool {
    let name = "findPointsOfInterest"
    let description = "Finds points of interest for a landmark."
    
    let landmark: Landmark
    
    @MainActor var lookupHistory: [Lookup] = []
    
    init(landmark: Landmark) {
        self.landmark = landmark
    }

    @Generable
    enum Category: String, CaseIterable {
        case campground
        case hotel
        case cafe
        case museum
        case marina
        case restaurant
        case nationalMonument
    }

    @Generable
    struct Arguments {
        @Guide(description: "This is the type of destination to look up for.")
        let pointOfInterest: Category

        @Guide(description: "The natural language query of what to search for.")
        let naturalLanguageQuery: String
    }
    
    @MainActor func recordLookup(arguments: Arguments) {
        lookupHistory.append(Lookup(history: arguments))
    }
    
    func call(arguments: Arguments) async throws -> String {
        // This sample app pulls some static data. Real-world apps can get creative.
        await recordLookup(arguments: arguments)
        let results = mapItems(arguments: arguments)
        return "There are these \(arguments.pointOfInterest) in \(landmark.name): \(results.joined(separator: ", "))"
    }
    
    private func mapItems(arguments: Arguments) -> [String] {
        suggestions(category: arguments.pointOfInterest)
    }
}
