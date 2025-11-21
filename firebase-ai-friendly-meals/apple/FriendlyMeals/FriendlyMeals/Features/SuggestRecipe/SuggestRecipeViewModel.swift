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

import FirebaseAI
import SwiftUI
import UIKit

@Observable
class SuggestRecipeViewModel {
  var isGenerating = false
  var isPresentingRecipe = false

  var ingredients = "Chopped tomatoes, aubergines, courgettes, parmesan cheese, garlic, olive oil"
  var notes = "Italian"
  var recipe = ""
  var recipeImage: UIImage?

  private var model: GenerativeModel = {
    let generationConfig = GenerationConfig(
      temperature: 0.9,
      topP: 0.1,
      topK: 16,
      maxOutputTokens: 4096,
      responseModalities: [.text, .image]
    )
    let firebaseAI = FirebaseAI.firebaseAI(backend: .vertexAI(location: "global"))
    return firebaseAI.generativeModel(
      modelName: "gemini-2.5-flash-image",
      generationConfig: generationConfig
    )
  }()

  func generateRecipe() async {
    isGenerating = true
    defer { isGenerating = false }
    recipeImage = nil

    var prompt = """
      Create a recipe using the following ingredients: \(ingredients).

      Also generate an image that shows what the final dish will look like.

      Please include:
      1. A creative title that describes the dish
      2. A brief, appetizing description
      3. Estimated cooking time in minutes
      4. List of ingredients with measurements
      5. Step-by-step cooking instructions
      """

    if !notes.isEmpty {
      prompt.append(
        """
        Please make sure to consider the following notes
        when creating the recipe: \(notes)
        """
      )
    }

    do {
      let response = try await model.generateContent(prompt)
      recipe = response.text ?? ""
      if let inlineDataPart = response.inlineDataParts.first {
        recipeImage = UIImage(data: inlineDataPart.data)
      }
    } catch {
      recipe = "An error occurred while generating the recipe: \(error.localizedDescription)."
    }
    isPresentingRecipe = true
  }

}
