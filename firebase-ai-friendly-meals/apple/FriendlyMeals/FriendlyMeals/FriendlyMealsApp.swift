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

import FirebaseCore
import SwiftUI

@main
struct FriendlyMealsApp: App {

  private func loadRocketSimConnect() {
    #if DEBUG
      guard
        Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load()
          == true
      else {
        print("Failed to load linker framework")
        return
      }
      print("RocketSim Connect successfully linked")
    #endif
  }

  init() {
    FirebaseApp.configure()
    loadRocketSimConnect()
  }

  var body: some Scene {
    let recipeService = RecipeService()
    return WindowGroup {
      TabView {
        NavigationStack {
          RecipeListView()
        }
        .tabItem {
          Label("Cookbook", systemImage: "book.closed")
        }

        NavigationStack {
          SuggestRecipeView()
        }
        .tabItem {
          Label("Suggest Recipe", systemImage: "wand.and.stars")
        }

        NavigationStack {
          MealPlannerChatView()
        }
        .tabItem {
          Label("Meal Planner", systemImage: "bubble.left.and.bubble.right")
        }

        NavigationStack {
          NutritionView()
        }
        .tabItem {
          Label("Nutrition", systemImage: "camera.macro")
        }
      }
      .environment(recipeService)
      .onAppear {
        Task {
          do {
            try await RemoteConfigService.shared.fetchConfig()
          } catch {
            print("Error fetching remote config: \(error.localizedDescription)")
          }
        }
      }
    }
  }
}
