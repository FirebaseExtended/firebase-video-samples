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
import FirebaseAuth
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
  private lazy var imageStore = RecipeImageStore()

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
          "cookTime": .string(),
          "prepTime": .string(),
          "ingredients": .array(items: .string()),
          "servings": .string(),
          "instructions": .string(),
          "tags": .array(items: .string())
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
      modelName: "gemini-2.5-flash-image",
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

    var prompt =
      """
      Create a detailed recipe based on these ingredients: \(ingredients).
      
      Format requirements:
      - 'instructions': Provide the cooking steps as a clear list of instructions separated by newlines. Use bold formatting on the step numbers. Use Markdown.
      - 'ingredients': List all necessary items, including quantities.
      - 'prepTime', 'cookTime', 'servings': Short strings (e.g., "15 mins").
      - 'tags': Generate a list of 3-5 relevant category tags (e.g., "Healthy", "Vegan", "Gluten-Free", "Dessert", "Quick").

      """

    if !notes.isEmpty {
      prompt.append("\n\nIMPORTANT CUISINE AND DIETARY NOTES: \(notes)")
    }

    do {
      let response = try await model.generateContent(prompt)
      if let jsonString = response.text {
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        let generatedRecipe = try decoder.decode(GeneratedRecipe.self, from: jsonData)
        self.recipe = Recipe(from: generatedRecipe, authorID: Auth.auth().currentUser?.uid)
        if let recipe {
          await generateImage(for: recipe)
        }
      }
      UsageTrackingService.shared.incrementGenerationCount()
    } catch {
      errorMessage = "An error occurred while generating the recipe: \(error)."
    }
    isPresentingRecipe = true
  }

  func generateImage(for recipe: Recipe) async {
    let prompt = "A photo of \(recipe.title)"
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

  func addRecipe(to store: RecipeStore) async {
    if var recipe = recipe,
       let image = recipeImage {
      do {
        let url = try await imageStore.saveImage(image)
        recipe.imageUri = url.absoluteString
        try await store.add(recipe)
      } catch {
        print("Error writing recipe to store: \(error)")
      }
    }
  }

  func writeLike(_ newLike: Bool, to store: LikesStore) {
    guard let like = recipe?.id.flatMap({
      RecipeLike(recipeID: $0)
    }) else {
      print("No recipe to like")
      return
    }
    do {
      if newLike {
        try store.addLike(like)
      } else {
        store.removeLike(like)
      }
    } catch {
      print("Error writing like to store: \(error)")
    }
  }

}
