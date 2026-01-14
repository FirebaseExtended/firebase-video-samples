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
  @Environment(LikesStore.self) private var likesStore
  @State @MainActor private var showFilterView = false

  var body: some View {
    List(recipeStore.recipes) { recipe in
      NavigationLink(value: recipe) {
        HStack {
          AsyncImage(
            url: recipe.imageUri.flatMap(URL.init(string:))
          )
          .scaledToFill()
          .frame(width: 80, height: 80)
          .clipShape(Capsule())
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
          VStack(alignment: .leading) {
            Text(recipe.title)
              .font(.headline)
          }
          Spacer()
          if likesStore.isLiked(recipe) {
            Image(systemName: "heart.fill")
              .foregroundColor(.pink)
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
            do {
              try await likesStore.toggleLikeIfAuthenticated(recipe: recipe)
            } catch {
              print("Unable to like recipe: \(error)")
            }
          }
        } label: {
          Label("Favorite", systemImage: likesStore.isLiked(recipe) ? "heart.slash" : "heart")
        }
        .tint(likesStore.isLiked(recipe) ? .gray : .pink)
      }
    }
    .navigationTitle("Cookbook")
    .navigationDestination(for: Recipe.self) { recipe in
      RecipeDetailsView(recipe: recipe,
                        isLiked: likesStore.isLiked(recipe),
                        onLike: { newLike in
        Task {
          do {
            try await likesStore.toggleLikeIfAuthenticated(recipe: recipe)
          } catch {
            print("Unable to like recipe: \(error)")
          }
        }
      })
    }
    .toolbar {
      Button("Filters") {
        showFilterView = true
      }
      .sheet(isPresented: $showFilterView) {
        FilterView(tags: recipeStore.topTags, configuration: recipeStore.filterConfiguration) { configuration in
          recipeStore.applyConfiguration(configuration)
          Task {
            do {
              try await recipeStore.fetchRecipes()
            } catch {
              print("Unable to fetch filtered results: \(error)")
            }
            showFilterView = false
          }
        }
      }
    }
    .task {
      do {
        try await likesStore.fetchLikesForDefaultUser()
      } catch {
        print("Error fetching recipes: \(error)")
      }
      do {
        try await recipeStore.fetchRecipes()
      } catch {
        print("Error fetching recipes: \(error)")
      }
      do {
        try await recipeStore.fetchPopularTags()
      } catch {
        print("Error fetching tags: \(error)")
      }
    }
  }
}

#Preview {
  NavigationStack {
    RecipeListView()
      .environment(RecipeStore())
  }
}
