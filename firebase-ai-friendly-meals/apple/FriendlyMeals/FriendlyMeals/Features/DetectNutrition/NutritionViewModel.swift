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
import Foundation
import SwiftUI

struct NutritionInfo: Codable, Equatable {
  let detectedDish: String
  let carbohydrates: Int
  let fat: Int
  let protein: Int
  let energy: Int
}

extension NutritionInfo {
  var facts: [(label: String, value: String, systemImage: String)] {
    [
      ("Carbohydrates", carbohydrates.description, "leaf.fill"),
      ("Fat", fat.description, "circle.grid.cross.fill"),
      ("Protein", protein.description, "circle.hexagongrid.fill"),
      ("Energy", energy.description, "flame.fill"),
    ]
  }
}

@Observable
@MainActor
class NutritionViewModel {
  var selectedImage: UIImage? = nil
  var isLoading = false
  var nutritionInfo: NutritionInfo? = nil
  var errorMessage: String? = nil
  var currentThoughtStep: ThoughtStep? = nil

  private let model: GenerativeModel
  init() {
    let nutritionSchema = Schema.object(
      properties: [
        "detectedDish": .string(),
        "carbohydrates": .integer(description: "The carbs in the dish, in grams",
                                  title: "Carbohydrates (g)"),
        "fat": .integer(description: "The fat in the dish, in grams",
                        title: "Fat (g"),
        "protein": .integer(description: "The protein in the dish, in grams",
                            title: "Protein (g"),
        "energy": .integer(description: "The total calories in the dish",
                           title: "Energy (kcal"),
      ]
    )

    let generationConfig = GenerationConfig(
      responseMIMEType: "application/json",
      responseSchema: nutritionSchema,
      thinkingConfig: ThinkingConfig(thinkingBudget: -1, includeThoughts: true)
    )

    let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    self.model = ai.generativeModel(
      modelName: "gemini-3-pro-preview",
      generationConfig: generationConfig
    )
  }

  func processImage(_ image: UIImage) {
    self.selectedImage = image
    self.errorMessage = nil
    self.nutritionInfo = nil
    self.isLoading = true
    self.currentThoughtStep = nil

    Task {
      do {
        let prompt = """
          Identify the dish in this image and analyze its nutritional values, including carbohydrates, fat, protein, and kilocalories. Provide the detected dish name along with the nutritional information.
          """

        let contentStream = try model.generateContentStream(image, prompt)

        var accumulatedText = ""
        for try await chunk in contentStream {
          if let thoughtSummary = chunk.thoughtSummary, let newStep = ThoughtStep(from: thoughtSummary) {
            self.currentThoughtStep = newStep
          }

          if let text = chunk.text {
            accumulatedText += text
          }
        }

        // After the stream, parse the accumulated text for the final JSON
        if accumulatedText.isEmpty {
          throw NutritionError.noTextInResponse
        }

        do {
          let jsonData = Data(accumulatedText.utf8)
          let decoder = JSONDecoder()
          self.nutritionInfo = try decoder.decode(NutritionInfo.self, from: jsonData)

          // Set final thought step on success
          self.currentThoughtStep = ThoughtStep(
            headline: "Analysis Complete",
            description: "The nutritional analysis for \(self.nutritionInfo?.detectedDish ?? "your dish") is ready!"
          )
        } catch let error as DecodingError {
          throw NutritionError.responseDecodingFailed(error)
        } catch {
          throw error  // Re-throw other errors
        }

      } catch let error as NutritionError {
        self.errorMessage = error.errorDescription
        print("Error processing image: \(String(describing: self.errorMessage))")
      } catch {
        self.errorMessage = error.localizedDescription
        print("An unexpected error occurred: \(error.localizedDescription)")
      }
      self.isLoading = false
    }
  }
}
