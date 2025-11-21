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

struct SuggestRecipeView: View {
  @State private var viewModel = SuggestRecipeViewModel()

  var body: some View {
    Form {
      Section("Ingredients") {
        TextField(
          "Enter ingredients",
          text: $viewModel.ingredients,
          axis: .vertical
        )
        .lineLimit(10...10)
      }
      Section("Notes") {
        TextField(
          "Any notes or preferred cuisines?",
          text: $viewModel.notes,
          axis: .vertical
        )
        .lineLimit(10...10)
      }
      Section {
        Button(action: {
          Task {
            await viewModel.generateRecipe()
          }
        }) {
          if viewModel.isGenerating {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle())
              .padding(.horizontal)
          } else {
            Text("Suggest Recipe")
              .frame(maxWidth: .infinity)
          }
        }
        .disabled(viewModel.ingredients.isEmpty || viewModel.isGenerating)
      }
    }
    .navigationTitle("Suggest a recipe")
    .sheet(isPresented: $viewModel.isPresentingRecipe) {
      NavigationStack {
        SuggestRecipeDetailsView(recipe: viewModel.recipe, image: viewModel.recipeImage)
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(action: { viewModel.isPresentingRecipe.toggle() }) {
                Label("Close", systemImage: "xmark")
              }
            }
          }
      }
    }

  }
}

#Preview {
  SuggestRecipeView()
}
