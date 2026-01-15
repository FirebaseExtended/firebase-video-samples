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

struct FilterConfiguration {

  enum SortOptions: String, CaseIterable, Identifiable {
    case none = "None"
    case rating = "Rating"
    case alphabetical = "Alphabetical"
    case popularity = "Popularity"
    
    var id: String { rawValue }
  }

  static let sortOptions: [SortOptions] = SortOptions.allCases

  var shouldShowOnlyOwnRecipes: Bool = false

  var recipeTitle = ""

  var minimumRating: Double = 0

  var selectedTags: Set<String> = []

  var sortOption = sortOptions[0]

}

struct FilterView: View {
  @Environment(\.dismiss) var dismiss

  init(
    tags: [String],
    configuration: FilterConfiguration? = FilterConfiguration(),
    applyFilters: @escaping (FilterConfiguration) -> ()
  ) {
    self.tags = tags
    self.applyFilters = applyFilters
    
    let initialConfig = configuration ?? FilterConfiguration()
    _configuration = State(initialValue: initialConfig)
  }

  let tags: [String]
  let applyFilters: (FilterConfiguration) -> ()

  @State private var configuration: FilterConfiguration

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("General")) {
          Toggle(isOn: $configuration.shouldShowOnlyOwnRecipes) {
            Text("View only my recipes")
          }
          
          TextField("Filter by title", text: $configuration.recipeTitle)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        }
        
        Section(header: Text("Rating")) {
          HStack {
            Text("Minimum rating: \(configuration.minimumRating.formatted())")
            Spacer()
            StarRatingView(rating: $configuration.minimumRating)
          }
        }
        
        Section(header: Text("Tags")) {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(tags, id: \.self) { tag in
                let isSelected = configuration.selectedTags.contains(tag)
                Toggle(tag, isOn: Binding(
                  get: { isSelected },
                  set: { isSelected in
                    if isSelected {
                      configuration.selectedTags.insert(tag)
                    } else {
                      configuration.selectedTags.remove(tag)
                    }
                  }
                ))
                .toggleStyle(.button)
                .tint(isSelected ? .blue : .secondary)
              }
            }
            .padding(.vertical, 4)
          }
        }
        
        Section(header: Text("Sort by")) {
          Picker("Choose a sort method", selection: $configuration.sortOption) {
            ForEach(FilterConfiguration.SortOptions.allCases) { option in
              Text(option.rawValue).tag(option)
            }
          }
        }
        
        Section {
          Button(role: .destructive) {
             configuration = FilterConfiguration()
          } label: {
             Text("Reset Filters")
               .frame(maxWidth: .infinity)
          }
        }
      }
      .navigationTitle("Filters")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Label("Cancel", systemImage: "xmark")
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button {
            applyFilters(configuration)
            dismiss()
          } label: {
            Label("Apply", systemImage: "checkmark")
          }
        }
      }
    }
  }

}

