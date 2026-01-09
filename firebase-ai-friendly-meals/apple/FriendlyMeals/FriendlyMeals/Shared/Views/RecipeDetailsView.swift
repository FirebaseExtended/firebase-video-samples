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
  let errorMessage: String?
  let placeholderImage: UIImage?
  var isNew = false
  var onSave: (() -> Void)? = nil

  init(recipe: Recipe?, placeholderImage: UIImage? = nil, errorMessage: String? = nil, isNew: Bool = false, onSave: (() -> Void)? = nil) {
    self.recipe = recipe
    self.errorMessage = errorMessage
    self.isNew = isNew
    self.onSave = onSave
    self.placeholderImage = placeholderImage
  }
}

extension RecipeDetailsView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        let url = recipe?.imageUri.flatMap(URL.init)
        AsyncImage(url: url) { image in
          image
            .resizable()
            .scaledToFit()
            .cornerRadius(8)
            .padding(.horizontal)
        } placeholder: {
          if let placeholderImage {
            Image(uiImage: placeholderImage)
              .resizable()
              .scaledToFit()
              .cornerRadius(8)
              .padding(.horizontal)
          } else {
            Color.gray
          }
        }
        if let recipe {
          VStack(alignment: .leading, spacing: 16) {
            Text(recipe.title)
              .font(.largeTitle)
              .bold()

            HStack {
              Image(systemName: "clock")
              Text("Cooking time: \(recipe.cookTime)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Section("Ingredients") {
              ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack(alignment: .top) {
                  Text("•")
                  Text("\(ingredient)")
                }
              }
            }

            Section("Instructions") {
              let markdownRender = try? AttributedString(
                markdown: recipe.instructions,
                options: AttributedString.MarkdownParsingOptions(
                  interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
              )
              markdownRender.map(Text.init) ?? Text(recipe.instructions)
            }
            Section(header: Text("Tags").font(.subheadline)) {
              ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                  ForEach(recipe.tags, id: \.self) { tag in
                    Text(tag)
                      .font(.caption.bold())
                      .foregroundColor(.white)
                      .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                      .background(.green)
                      .clipShape(Capsule())
                  }
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
      instructions:
        """
        In a large pot, heat olive oil over medium heat. Add chopped onion and garlic and cook until softened.
        Add the rice and stir for 1 minute until toasted.",
        Pour in the white wine and cook until it has been absorbed, stirring constantly.
        Add the vegetable broth, one ladle at a time, waiting until it is absorbed before adding more.
        In a separate pan, cook the mushrooms with butter until browned.
        Once the rice is cooked, stir in the mushrooms, parmesan cheese, salt, and pepper.
        Serve immediately.
        """
      ,
      ingredients: [
        "Chicken stock",
        "Arborio rice",
        "Mushrooms",
        "Vegetable broth",
        "Onion",
        "Parmesan cheese",
        "White wine",
        "Olive oil",
        "Garlic",
        "Butter",
        "Salt and pepper",
      ],
      authorId: "no author",
      tags: [],
      averageRating: 4.5,
      imageUri: "https://www.gstatic.com/devrel-devsite/prod/ve08add287a6b4bdf8961ab8a1be50bf551be3816cdd70b7cc934114ff3ad5f10/firebase/images/lockup.svg",
      prepTime: "30 minutes",
      cookTime: "10 minutes",
      servings: "3-5 servings"
    ),
  )
}

#Preview("With Error") {
  RecipeDetailsView(
    recipe: nil,
    errorMessage: "An error occurred while generating the recipe: The operation couldn’t be completed. (GoogleGenerativeAI.GenerateContentError error 1.)"
  )
}
