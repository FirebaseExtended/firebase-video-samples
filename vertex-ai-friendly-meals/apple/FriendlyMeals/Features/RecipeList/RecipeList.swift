//
// RecipeList.swift
// FriendlyMeals
//
// Created by Peter Friese on 15.04.25.
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
import IdentityKit

@MainActor
struct RecipeList {
  @State private var searchText = ""

  var filteredRecipes: [Recipe] {
    if searchText.isEmpty {
      return Recipe.mockList
    } else {
      return Recipe.mockList.filter { recipe in
        recipe.title.localizedCaseInsensitiveContains(searchText) ||
        recipe.description.localizedCaseInsensitiveContains(searchText) ||
        recipe.cuisine.rawValue.localizedCaseInsensitiveContains(searchText)
      }
    }
  }
}

extension RecipeList: View {
  var body: some View {
    NavigationStack {
      List(filteredRecipes) { recipe in
        NavigationLink(value: recipe) {
          RecipeRowView(recipe: recipe)
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Search recipes")
      .navigationTitle("Recipes")
      .navigationDestination(for: Recipe.self) { recipe in
        RecipeDetailsView(recipe: recipe)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Add", systemImage: "plus") {
          }
        }
      }
      .withAuthenticationToolbar()
    }
  }
}

#Preview {
  RecipeList()
    .environment(AuthenticationService.shared)
}
