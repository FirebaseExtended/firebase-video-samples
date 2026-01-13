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
import ConversationKit
import FirebaseAI

struct MealPlannerChatView: View {
  @State private var viewModel = MealPlannerChatViewModel()

  var body: some View {
    NavigationStack {
      ConversationView(messages: $viewModel.messages)
        .onSendMessage { userMessage in
          Task {
            await viewModel.sendMessageStreaming(userMessage)
          }
        }
        .navigationTitle("Meal Planner")
    }
  }
}

#Preview {
  MealPlannerChatView()
}
