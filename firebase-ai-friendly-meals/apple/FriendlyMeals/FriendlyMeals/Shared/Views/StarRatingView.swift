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

struct StarRatingView: View {
  @Binding var rating: Double
  
  var maxRating: Int = 5
  
  var body: some View {
    HStack(spacing: 4) {
      ForEach(1...maxRating, id: \.self) { index in
        Image(systemName: starType(for: index))
          .foregroundColor(.yellow)
          .overlay(
            GeometryReader { g in
              HStack(spacing: 0) {
                Color.clear
                  .contentShape(Rectangle())
                  .onTapGesture {
                    rating = Double(index) - 0.5
                  }
                Color.clear
                  .contentShape(Rectangle())
                  .onTapGesture {
                    rating = Double(index)
                  }
              }
            }
          )
      }
    }
  }

  func starType(for index: Int) -> String {
    if rating >= Double(index) {
      return "star.fill"
    } else if rating >= Double(index) - 0.5 {
      return "star.leadinghalf.fill"
    } else {
      return "star"
    }
  }
}
