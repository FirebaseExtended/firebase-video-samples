/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that displays a featured landmark.
*/

import SwiftUI

struct LandmarkFeaturedItemView: View {
    let landmark: Landmark

    var body: some View {
        NavigationLink(destination: TripPlanningView(landmark: landmark)) {
            Image(landmark.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay {
                    ReadabilityRoundedRectangle()
                }
                .clipped()
                .cornerRadius(15.0)
                .overlay(alignment: .bottomLeading) {
                    Text(landmark.name)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding([.leading, .bottom], FoundationModelsTripPlannerApp.Padding.standard)
                }
        }
        .buttonStyle(.plain)
    }
}
