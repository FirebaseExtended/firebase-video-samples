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
import FirebaseRemoteConfig
import SwiftUI
import UIKit

@Observable
class MealPlannerSuggestionViewModel {
  var isGenerating = false
  var isPresentingRecipe = false

  var ingredients = "Chopped tomatoes, aubergines, courgettes, parmesan cheese, garlic, olive oil"
  var notes = "Italian"
  var recipe: Recipe?
  var isPresentingPaywall = false
  var recipeImage: UIImage?
  var errorMessage: String?

  @ObservationIgnored
  private lazy var model: GenerativeModel = {
    let generationConfig = GenerationConfig(
      temperature: 0.9,
      topP: 0.1,
      topK: 16,
      maxOutputTokens: 4096,
      responseMIMEType: "application/json",
      responseSchema: .object(
        properties: [
          "title": .string(),
          "description": .string(),
          "cookingTime": .integer(),
          "ingredients": .array(items: .object(properties: [
            "name": .string(),
            "amount": .string()
          ])),
          "instructions": .array(items: .string())
        ]
      ),
      responseModalities: [.text]
    )
    let firebaseAI = FirebaseAI.firebaseAI(backend: .googleAI())
    return firebaseAI.generativeModel(
      modelName: "gemini-2.5-flash",
      generationConfig: generationConfig
    )
  }()

  @ObservationIgnored
  private lazy var imageModel: GenerativeModel = {
    let firebaseAI = FirebaseAI.firebaseAI(backend: .googleAI())
    return firebaseAI.generativeModel(
      modelName: "gemini-2.5-flash-image-preview",
      generationConfig: GenerationConfig(responseModalities: [.image])
    )
  }()

  func generateRecipe() async {
    if !UsageTrackingService.shared.canGenerate() {
      isPresentingPaywall = true
      return
    }

    isGenerating = true
    defer { isGenerating = false }
    recipeImage = nil
    recipe = nil
    errorMessage = nil

    var prompt = "Create a recipe using the following ingredients: \(ingredients)."

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
      if let jsonString = response.text {
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        let generatedRecipe = try decoder.decode(GeneratedRecipe.self, from: jsonData)
        self.recipe = Recipe(from: generatedRecipe)
        if let recipe {
          await generateImage(for: recipe)
        }
      }
      UsageTrackingService.shared.incrementGenerationCount()
      isPresentingRecipe = true
    } catch {
      errorMessage = "An error occurred while generating the recipe: \(error.localizedDescription)."
      isPresentingRecipe = true
    }
  }

  func generateImage(for recipe: Recipe) async {
    let prompt = "A photo of \(recipe.title), \(recipe.description)"
    do {
      let response = try await imageModel.generateContent(prompt)
      if let inlineDataPart = response.inlineDataParts.first {
        recipeImage = UIImage(data: inlineDataPart.data)
      }
    }
    catch {
      print("Error generating image: \(error.localizedDescription)")
    }
  }

}
