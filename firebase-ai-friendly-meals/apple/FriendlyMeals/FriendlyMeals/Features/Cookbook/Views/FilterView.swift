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

struct FilterConfiguration {

  enum SortOptions: String {
    case none = "None"
    case rating = "Rating"
    case alphabetical = "Alphabetical"
    case popularity = "Popularity"
  }

  static let sortOptions: [SortOptions] = [.none, .rating, .alphabetical, .popularity]

  var shouldShowOnlyOwnRecipes: Bool = false

  var recipeTitle = ""

  var minimumRating: Double = 0

  var selectedTags: Set<String> = []

  var sortOption = sortOptions[0]

}

struct FilterView: View {

  init(
    tags: [String],
    configuration: FilterConfiguration = FilterConfiguration(),
    applyFilters: @escaping (FilterConfiguration) -> ()
  ) {
    self.tags = tags
    self.tagSelections = Array(repeating: false, count: tags.count)
    self.configuration = configuration
    self.applyFilters = applyFilters
  }

  var tags: [String] {
    didSet {
      tagSelections = Array(repeating: false, count: tags.count)
    }
  }

  private let applyFilters: (FilterConfiguration) -> ()

  @State private var tagSelections: [Bool]
  @State private var configuration: FilterConfiguration

  var body: some View {
    VStack(alignment: .leading) {
      Text("Filters")
        .font(.largeTitle)

      Toggle(isOn: $configuration.shouldShowOnlyOwnRecipes) {
        Text("View only my recipes")
      }

      Text("Filter by title")
      TextField("Scallops", text: $configuration.recipeTitle)

      Text("Minimum rating: \(configuration.minimumRating.formatted())")
      Slider(
        value: $configuration.minimumRating,
        in: 0...5,
        step: 0.25
      ) {
        Text("Minimum rating")
      } minimumValueLabel: {
        Text("0")
      } maximumValueLabel: {
        Text("5")
      } onEditingChanged: { _ in
        // do nothing
      }

      Text("Tags")
      ScrollView(.horizontal, showsIndicators: true) {
        HStack {
          ForEach(0 ..< tags.count, id: \.self) { index in
            let tag = tags[index]
            let isSelected = tagSelections[index]
            Toggle(tag, isOn: $tagSelections[index])
              .toggleStyle(.button)
              .tint(isSelected ? .blue : .secondary)
          }
        }
      }

      Text("Sort by")
      Picker("Choose a sort method", selection: $configuration.sortOption) {
        ForEach(FilterConfiguration.sortOptions, id: \.self) { option in
          Text(option.rawValue).tag(option.rawValue)
        }
      }

      HStack {
        Button("Remove filters") {
          configuration = FilterConfiguration()
          tagSelections = tagSelections.map { _ in false }
        }
        Button("Apply filters") {
          let selectedTags = tags.indices
            .filter { tagSelections[$0] }
            .map { tags[$0] }
          configuration.selectedTags = Set(selectedTags)
          applyFilters(configuration)
        }
      }
      Spacer()
    }
    .padding(16)
  }

}
