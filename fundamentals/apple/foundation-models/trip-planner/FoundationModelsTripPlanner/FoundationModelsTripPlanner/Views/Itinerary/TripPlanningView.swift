/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for displaying the appropriate view based on the availability of the System Language Model.
*/

import FoundationModels
import SwiftUI

struct TripPlanningView: View {
    let landmark: Landmark
    private let model = SystemLanguageModel.default
    
    var body: some View {
        switch model.availability {
        case .available:
            LandmarkTripView(landmark: landmark)
        case .unavailable(.appleIntelligenceNotEnabled):
            MessageView(
                landmark: self.landmark,
                message: """
                         Trip Planner is unavailable because \
                         Apple Intelligence hasn't been turned on.
                         """
            )
        case .unavailable(.modelNotReady):
            MessageView(
                landmark: self.landmark,
                message: "Trip Planner isn't ready yet. Try again later."
            )
        default:
            ScrollView {
                LandmarkDescriptionView(
                    landmark: landmark
                )
            }
            .headerStyle(landmark: landmark)
        }
    }
}
