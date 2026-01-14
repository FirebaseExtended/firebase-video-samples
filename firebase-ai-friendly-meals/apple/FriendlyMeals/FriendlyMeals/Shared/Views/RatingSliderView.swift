//
// FriendlyMeals
//
// Copyright © 2026 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

struct RatingSliderView: View {
  // A binding to store the selected rating value (supports half stars)
  @Binding var rating: Double
  var maxRating: Int = 5
  var onColor: Color = .yellow
  var offColor: Color = .gray

  var body: some View {
    HStack(spacing: 0) {
      // Display the stars visually
      ForEach(1...maxRating, id: \.self) { index in
        Image(systemName: starType(for: index))
          .foregroundColor(onColor)
          .font(.title)
          .aspectRatio(contentMode: .fit)
      }
    }
    .overlay(
      // A transparent Slider overlaid on the stars for interaction
      GeometryReader { geometry in
        let range = 0...Double(maxRating)
        Slider(value: $rating, in: range, step: 1)
          .tint(.clear)
          .opacity(0.1)
          .gesture(DragGesture(minimumDistance: 0).onEnded { value in
              let percent = min(max(0, Double(value.location.x / geometry.size.width * 1)), 1)
              let newValue = range.lowerBound + round(percent * (range.upperBound - range.lowerBound))
            rating = newValue
          })
      }
    )
    // Ensure accessibility representation is a slider
    .accessibilityRepresentation {
      Slider(value: $rating, in: 0...Double(maxRating), step: 0.5)
    }
  }

  // Helper function to determine which star SFSymbol to use
  private func starType(for index: Int) -> String {
    let starIndex = Double(index)
    if starIndex <= rating {
      return "star.fill" // Full star
    } else if starIndex - 0.5 <= rating {
      return "star.leadinghalf.fill" // Half star
    } else {
      return "star" // Empty star
    }
  }
}
