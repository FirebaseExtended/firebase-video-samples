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

struct RecipeDetailsView {
  @Environment(\.dismiss) private var dismiss

  let recipe: Recipe?
  let image: UIImage?
  let errorMessage: String?
  var isNew = false
  var onSave: (() -> Void)? = nil

  init(recipe: Recipe?, image: UIImage?, errorMessage: String? = nil, isNew: Bool = false, onSave: (() -> Void)? = nil) {
    self.recipe = recipe
    self.image = image
    self.errorMessage = errorMessage
    self.isNew = isNew
    self.onSave = onSave
  }
}

extension RecipeDetailsView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        if let image {
          Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(8)
            .padding(.horizontal)
        }
        if let recipe {
          VStack(alignment: .leading, spacing: 16) {
            Text(recipe.title)
              .font(.largeTitle)
              .bold()

            Text(recipe.description)
              .font(.body)

            HStack {
              Image(systemName: "clock")
              Text("Cooking time: \(recipe.cookingTime) minutes")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Section("Ingredients") {
              ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack(alignment: .top) {
                  Text("•")
                  Text("\(ingredient.amount) \(ingredient.name)")
                }
              }
            }

            Section("Instructions") {
              ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top) {
                  Text("\(index + 1).")
                  Text(instruction)
                }
              }
            }
          }
          .padding()
        }
        if let errorMessage {
          Text(errorMessage)
            .font(.body)
            .padding()
        }
      }
    }
    .toolbar {
      if isNew {
        Button(action: {
          onSave?()
          dismiss()
        }) {
          Label("Save", systemImage: "square.and.arrow.down")
        }
      }
    }
  }
}

#Preview("With Recipe") {
  RecipeDetailsView(
    recipe: Recipe(
      title: "Mushroom Risotto",
      description: "A creamy and delicious risotto with mushrooms.",
      cookingTime: 45,
      ingredients: [
        .init(name: "Chicken stock", amount: "1 cup"),
        .init(name: "Arborio rice", amount: "1 cup"),
        .init(name: "Mushrooms", amount: "200g"),
        .init(name: "Vegetable broth", amount: "4 cups"),
        .init(name: "Onion", amount: "1"),
        .init(name: "Parmesan cheese", amount: "1/2 cup"),
        .init(name: "White wine", amount: "1/4 cup"),
        .init(name: "Olive oil", amount: "2 tbsp"),
        .init(name: "Garlic", amount: "2 cloves"),
        .init(name: "Butter", amount: "2 tbsp"),
        .init(name: "Salt and pepper", amount: "to taste")
      ],
      instructions: [
        "In a large pot, heat olive oil over medium heat. Add chopped onion and garlic and cook until softened.",
        "Add the rice and stir for 1 minute until toasted.",
        "Pour in the white wine and cook until it has been absorbed, stirring constantly.",
        "Add the vegetable broth, one ladle at a time, waiting until it is absorbed before adding more.",
        "In a separate pan, cook the mushrooms with butter until browned.",
        "Once the rice is cooked, stir in the mushrooms, parmesan cheese, salt, and pepper.",
        "Serve immediately."
      ]
    ),
    image: UIImage(systemName: "photo")
  )
}

#Preview("With Error") {
  RecipeDetailsView(
    recipe: nil,
    image: nil,
    errorMessage: "An error occurred while generating the recipe: The operation couldn’t be completed. (GoogleGenerativeAI.GenerateContentError error 1.)"
  )
}
