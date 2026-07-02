/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Project utilites for logging, UI, and other miscellaneous needs.
*/

import SwiftUI
import MapKit
import os

enum Logging {
    static let subsystem = "com.example.apple-samplecode.FoundationModelsTripPlanner"

    static let general = Logger(subsystem: subsystem, category: "General")
}

extension FoundationModelsTripPlannerApp {
    static let minimumLandmarkWidth: CGFloat = 120.0

    static var maximumFullGridWidth: CGFloat {
        return minimumLandmarkWidth * 4.0 + (5 * Padding.landmarkGrid)
    }
    
    struct Padding {
        static let standard: CGFloat = 20.0
        static let matchesNavigationTitle: CGFloat = 26.0
        static let landmarkGrid: CGFloat = 8.0
        static let collectionGrid: CGFloat = 8.0
    }
}

struct ReadabilityRoundedRectangle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16.0)
            .fill(
                LinearGradient(
                    colors: [.black.opacity(0.8), .clear],
                    startPoint: .bottom,
                    endPoint: .center
                )
            )
    }
}

extension Kind {
    var symbolName: String {
        switch self {
        case .sightseeing: "binoculars.fill"
        case .foodAndDining: "fork.knife"
        case .shopping: "bag.fill"
        case .hotelAndLodging: "bed.double.fill"
        }
    }
}

extension FindPointsOfInterestTool {
    static var categories: String {
        Category.allCases.map {
            $0.rawValue
        }.joined(separator: ", ")
    }
    
    struct Lookup: Identifiable {
        let id = UUID()
        let history: FindPointsOfInterestTool.Arguments
    }
}
