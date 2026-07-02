/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main UI that presents the landmarks.
*/

import SwiftUI

struct LandmarksView: View {
    @Environment(ModelData.self) var modelData

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: FoundationModelsTripPlannerApp.Padding.standard) {
                        Text("Featured")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let featuredLandmark = modelData.featuredLandmark {
                            LandmarkFeaturedItemView(landmark: featuredLandmark)
                        }
                            
                        ForEach(modelData.landmarksByContinent.keys.sorted(), id: \.self) { continent in
                            Group {
                                Text(continent)
                                    .font(.title)
                                    .bold()
                                if let landmarkList = modelData.landmarksByContinent[continent] {
                                    LandmarkHorizontalListView(landmarkList: landmarkList)
                                        .frame(height: landmarkHeight(in: geometry))
                                }
                            }
                        }
                    }
                    .safeAreaPadding(FoundationModelsTripPlannerApp.Padding.standard)
                }
                .navigationTitle("Foundation Models Trip Planner")
            }
        }
    }
    
    private func featuredHeight(in geometry: GeometryProxy) -> CGFloat {
        let baseHeight = geometry.size.height
        let heightAdjustedByPadding = baseHeight - (2 * FoundationModelsTripPlannerApp.Padding.standard)
        let featuredHeight = heightAdjustedByPadding / 3
        return featuredHeight
    }

    private func featuredWidth(in geometry: GeometryProxy) -> CGFloat {
        let baseWidth = geometry.size.width
        let widthAdjustedByPadding = baseWidth - FoundationModelsTripPlannerApp.Padding.standard * 2
        return widthAdjustedByPadding
    }

    private func landmarkHeight(in geometry: GeometryProxy) -> CGFloat {
        let baseWidth = geometry.size.width
        let widthAdjustedByPadding = baseWidth - (3 * FoundationModelsTripPlannerApp.Padding.standard)
        guard widthAdjustedByPadding >= 0 else {
            return 0.0
        }
        var landmarksPerLine = 2.75
        if widthAdjustedByPadding < 550 {
            landmarksPerLine = 2.1
        }
        if widthAdjustedByPadding < 400 {
            landmarksPerLine = 1.1
        }
        let landmarkWidth = widthAdjustedByPadding / landmarksPerLine
        let landmarkHeight = landmarkWidth / 1.4
        return landmarkHeight
    }
}
