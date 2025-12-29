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
  @Environment(RecipeStore.self) private var recipeStore

  var body: some View {
    List(recipeStore.recipes) { recipe in
      NavigationLink(value: recipe) {
        HStack {
          VStack(alignment: .leading) {
            Text(recipe.title)
              .font(.headline)
          }
          Spacer()
          if recipe.isFavorite {
            Image(systemName: "star.fill")
              .foregroundColor(.yellow)
          }
        }
      }
      .swipeActions(edge: .trailing) {
        Button(role: .destructive) {
          Task {
            do {
              try await recipeStore.delete(recipe)
            } catch {
              print("Error deleting recipe: \(error)")
            }
          }
        } label: {
          Label("Delete", systemImage: "trash")
        }
      }
      .swipeActions(edge: .leading) {
        Button {
          Task {
            // TODO: add recipe to favorites
          }
        } label: {
          Label("Favorite", systemImage: recipe.isFavorite ? "star.slash" : "star")
        }
        .tint(recipe.isFavorite ? .gray : .yellow)
      }
    }
    .navigationTitle("Cookbook")
    .onAppear {
      recipeStore.fetchRecipes()
    }
    .navigationDestination(for: Recipe.self) { recipe in
      RecipeDetailsView(recipe: recipe, image: nil)
    }
  }
}

#Preview {
  NavigationStack {
    RecipeListView()
      .environment(RecipeStore())
  }
}
