/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that renders a Landmark location on a map.
*/

import SwiftUI
import MapKit

struct LandmarkDetailMapView: View {
    let landmark: Landmark
    var landmarkMapItem: MKMapItem?

    var body: some View {
        Map(initialPosition: .region(landmark.coordinateRegion), interactionModes: []) {
            if let landmarkMapItem = landmarkMapItem {
                Marker(item: landmarkMapItem)
            }
        }
        .disabled(true)
    }
}
