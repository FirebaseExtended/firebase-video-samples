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
  @Environment(RecipeStore.self) private var recipeStore

  let recipe: Recipe?
  let errorMessage: String?
  let placeholderImage: UIImage?
  var isNew = false
  var onSaveToServer: (() -> Void)? = nil
  var onSaveToUser: ((Bool) -> Void)? = nil

  @State var isSaved = false
  @State var rating: Double = 0

  init(recipe: Recipe?,
       placeholderImage: UIImage? = nil,
       errorMessage: String? = nil,
       isNew: Bool = false,
       isSaved: Bool = false,
       onSaveToServer: (() -> Void)? = nil,
       onSaveToUser: ((Bool) -> Void)? = nil) {
    self.recipe = recipe
    self.errorMessage = errorMessage
    self.isNew = isNew
    self.isSaved = isSaved
    self.onSaveToServer = onSaveToServer
    self.onSaveToUser = onSaveToUser
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

            if let id = recipe.id {
              HStack {
                Text("Rating: ")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
                let wholeStars = Int(rating)
                ForEach(0..<wholeStars, id: \.self) { index in
                  Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .aspectRatio(contentMode: .fit)
                    .padding(0)
                }
                let remainder = rating.truncatingRemainder(dividingBy: 1)
                if remainder > 0 {
                  partialStar(percentage: remainder)
                }
              }
              .task {
                do {
                  rating = try await recipeStore.fetchRating(recipeID: id)
                } catch {
                  print("unable to fetch recipe rating: \(error)")
                }
              }
            }
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
            if let id = recipe.id {
              Section("Leave a review") {
                RatingSliderView(rating: $rating)
                  .onChange(of: rating) { _, newRating in
                    if let review = Review(recipeID: id, rating: newRating) {
                      do {
                        try recipeStore.writeReview(review)
                      } catch {
                        print("Failed to write recipe review: \(error)")
                      }
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
          onSaveToServer?()
          dismiss()
        }) {
          Label("Save", systemImage: "square.and.arrow.down")
        }
      } else {
        Button(action: {
          onSaveToUser?(!isSaved)
          isSaved = !isSaved
        }) {
          let imageName = isSaved ? "heart.fill" : "heart"
          Label("Save", systemImage: imageName)
        }
      }
    }
  }

  private func partialStar(percentage: Double) -> ZStack<some View> {
    return ZStack {
      Image(systemName: "star")
        .foregroundColor(.clear)

      Image(systemName: "star.fill")
        .foregroundColor(.yellow)
        .mask {
          GeometryReader { geometry in
            Rectangle()
              .frame(width: geometry.size.width * percentage)
              .frame(maxWidth: .infinity, alignment: .leading)
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
