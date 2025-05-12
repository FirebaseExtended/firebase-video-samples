//
// ContentView.swift
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

struct AuthenticationToolbarContent: ViewModifier {
  @State private var showAuthSheet = false
  @Environment(AuthenticationService.self) private var authService

  func body(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            if authService.isAuthenticated {
              Task {
                try await authService.signOut()
              }
            } else {
              showAuthSheet = true
            }
          } label: {
            Image(systemName: authService.isAuthenticated ? "person.fill" : "person")
          }
        }
      }
      .sheet(isPresented: $showAuthSheet) {
        AuthenticationScreen()
          .authenticationProviders([.email, .apple])
      }
  }
}

extension View {
  func withAuthenticationToolbar() -> some View {
    modifier(AuthenticationToolbarContent())
  }
}

@MainActor
struct ContentView {
}

extension ContentView: View {
  var body: some View {
    TabView {
      RecipeList()
        .tabItem {
          Label("Recipes", systemImage: "fork.knife")
        }

      RecipeGenerationView()
        .tabItem {
          Label("Inspire Me", systemImage: "sparkles")
        }

      VisionRecipeGenerationView()
        .tabItem {
          Label("Vision", systemImage: "photo")
        }

      PersonalChefView()
        .tabItem {
          Label("Personal Chef", systemImage: "bubble.left.and.bubble.right")
        }
    }
    .withAuthenticationToolbar()
  }
}

#Preview {
  ContentView()
    .environment(AuthenticationService.shared)
}
