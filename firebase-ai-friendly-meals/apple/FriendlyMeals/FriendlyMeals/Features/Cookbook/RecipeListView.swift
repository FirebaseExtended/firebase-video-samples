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

struct RecipeListView: View {
  @Environment(RecipeService.self) private var recipeService

  var body: some View {
    List(recipeService.recipes) { recipe in
      NavigationLink(value: recipe) {
        HStack {
          VStack(alignment: .leading) {
            Text(recipe.title)
              .font(.headline)
            Text(recipe.description)
              .font(.subheadline)
              .lineLimit(2)
          }
          Spacer()
          if recipe.isFavorite ?? false {
            Image(systemName: "star.fill")
              .foregroundColor(.yellow)
          }
        }
      }
      .swipeActions(edge: .trailing) {
        Button(role: .destructive) {
          Task {
            try await recipeService.delete(recipe)
          }
        } label: {
          Label("Delete", systemImage: "trash")
        }
      }
      .swipeActions(edge: .leading) {
        Button {
          Task {
            var updatedRecipe = recipe
            updatedRecipe.isFavorite = !(recipe.isFavorite ?? false)
            try await recipeService.update(updatedRecipe)
          }
        } label: {
          Label("Favorite", systemImage: recipe.isFavorite ?? false ? "star.slash" : "star")
        }
        .tint(recipe.isFavorite ?? false ? .gray : .yellow)
      }
    }
    .navigationTitle("Cookbook")
    .onAppear {
      recipeService.fetchRecipes()
    }
    .navigationDestination(for: Recipe.self) { recipe in
      SuggestRecipeDetailsView(recipe: recipe, image: nil)
    }
  }
}

#Preview {
  NavigationStack {
    RecipeListView()
      .environment(RecipeService())
  }
}
