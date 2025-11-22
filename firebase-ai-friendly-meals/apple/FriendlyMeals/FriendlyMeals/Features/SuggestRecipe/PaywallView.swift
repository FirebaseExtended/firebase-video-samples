//
// FriendlyMeals
//
// Copyright © 2025 Google LLC.
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

struct PaywallView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ZStack(alignment: .topTrailing) {
      // Close Button
      Button(action: { dismiss() }) {
        Image(systemName: "xmark.circle.fill")
          .font(.title)
          .foregroundColor(.gray.opacity(0.6))
      }
      .padding()

      VStack(spacing: 20) {
        Spacer()

        // Icon
        Image(systemName: "crown.fill")
          .font(.system(size: 60))
          .foregroundColor(.yellow)

        // Title and Subtitle
        Text("Upgrade to Premium")
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text("Unlock unlimited recipe generations and more!")
          .font(.headline)
          .multilineTextAlignment(.center)
          .foregroundColor(.secondary)

        Spacer()

        // Feature List
        VStack(alignment: .leading, spacing: 15) {
          FeatureView(text: "Unlimited recipe suggestions")
          FeatureView(text: "Generate images for every recipe")
          FeatureView(text: "Save your favorite recipes")
          FeatureView(text: "Access exclusive meal plans")
        }
        .padding(.horizontal)

        Spacer()

        // Call to Action Button
        Button(action: {
          // Mock action
          print("Upgrade button tapped!")
          dismiss()
        }) {
          Text("Unlock Premium")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)

        // Restore Purchases Button
        Button(action: {
          // Mock action
          print("Restore purchases tapped!")
        }) {
          Text("Restore Purchases")
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.bottom)
      }
      .padding()
    }
  }
}

struct FeatureView: View {
  let text: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.blue)
      Text(text)
    }
  }
}

#Preview {
  PaywallView()
}
