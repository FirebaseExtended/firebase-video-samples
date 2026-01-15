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
import FirebaseCore
import FirebaseAuth

@main
struct FriendlyMealsApp: App {
  @State private var recipeStore: RecipeStore
  @State private var likesStore: LikesStore
  @State private var selectedTab: AppTab = .cookbook

  init () {
    FirebaseApp.configure()
    _recipeStore = State(initialValue: RecipeStore())
    _likesStore = State(initialValue: LikesStore())
  }

  var body: some Scene {
    WindowGroup {
      TabView(selection: $selectedTab) {
        NavigationStack {
          RecipeListView()
        }
        .tabItem {
          Label("Cookbook", systemImage: "book.closed")
        }
        .tag(AppTab.cookbook)

        NavigationStack {
          MealPlannerSuggestionView()
        }
        .tabItem {
          Label("Suggest Recipe", systemImage: "wand.and.stars")
        }
        .tag(AppTab.suggestRecipe)

        NavigationStack {
          MealPlannerChatView()
        }
        .tabItem {
          Label("Meal Planner", systemImage: "bubble.left.and.bubble.right")
        }
        .tag(AppTab.mealPlanner)
        
        NavigationStack {
          NutritionView()
        }
        .tabItem {
          Label("Nutrition", systemImage: "camera.macro")
        }
        .tag(AppTab.nutrition)

      }
      .environment(recipeStore)
      .environment(likesStore)
      .environment(\.selectedTab, $selectedTab)
      .task {
        // Fetch Remote Config params
        do {
          try await RemoteConfigService.shared.fetchConfig()
        } catch {
          print("Failed to fetch remote config: \(error)")
        }

        // Setup auth
        do {
          try await Auth.auth().signInAnonymously()
        } catch {
          print("Failed to authenticate anonymous user: \(error)")
        }
      }
    }
  }
}
