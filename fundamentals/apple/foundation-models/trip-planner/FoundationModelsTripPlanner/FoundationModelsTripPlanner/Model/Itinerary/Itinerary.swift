/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A Generable structure that defines an Itinerary, along with its nested types: DayPlan, Activity, and Kind.
*/

import Foundation
import FoundationModels

@Generable
struct Itinerary: Equatable {
    @Guide(description: "An exciting name for the trip.")
    let title: String
    @Guide(.anyOf(ModelData.landmarkNames))
    let destinationName: String
    let description: String
    @Guide(description: "An explanation of how the itinerary meets the person's special requests.")
    let rationale: String
    
    @Guide(description: "A list of day-by-day plans.")
    @Guide(.count(3))
    let days: [DayPlan]
}

@Generable
struct DayPlan: Equatable {
    @Guide(description: "A unique and exciting title for this day plan.")
    let title: String
    let subtitle: String
    let destination: String

    @Guide(.count(3))
    let activities: [Activity]
}

@Generable
struct Activity: Equatable {
    let type: Kind
    let title: String
    let description: String
    @Guide(description: "The latitude of the activity location, if known.")
    let latitude: Double?
    @Guide(description: "The longitude of the activity location, if known.")
    let longitude: Double?
}

@Generable
enum Kind: String {
    case sightseeing
    case foodAndDining
    case shopping
    case hotelAndLodging
    
    var displayName: String {
        switch self {
        case .sightseeing: return "Sightseeing"
        case .foodAndDining: return "Food & Dining"
        case .shopping: return "Shopping"
        case .hotelAndLodging: return "Hotel & Lodging"
        }
    }
}
