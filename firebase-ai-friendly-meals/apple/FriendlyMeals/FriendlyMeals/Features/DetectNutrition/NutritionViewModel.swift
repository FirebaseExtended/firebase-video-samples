import FirebaseAI
import Foundation
import SwiftUI

struct NutritionInfo: Identifiable, Codable {
  let id = UUID()
  let carbohydrates: String
  let fat: String
  let protein: String
  let kilocalories: String
}

@Observable
@MainActor
class NutritionViewModel {
  var selectedImage: UIImage? = nil
  var isLoading = false
  var nutritionInfo: NutritionInfo? = nil
  var errorMessage: String? = nil

  private var model: GenerativeModel {
    let generationConfig = GenerationConfig(
      responseMIMEType: "application/json",
      responseSchema: .object(
        properties: [
          "carbohydrates": .string(),
          "fat": .string(),
          "protein": .string(),
          "kilocalories": .string(),
        ]
      )
    )
    let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    return ai.generativeModel(
      modelName: "gemini-2.5-flash",
      generationConfig: generationConfig
    )
  }

  func processImage(_ image: UIImage) {
    self.selectedImage = image
    self.errorMessage = nil
    self.nutritionInfo = nil
    self.isLoading = true

    Task {
      do {
        let prompt =
          "Analyze the nutritional values of the food in this image, including carbohydrates, fat, protein, and kilocalories. Provide a concise summary of each value."
        let response = try await model.generateContent(image, prompt)

        if let jsonString = response.text {
          let jsonData = Data(jsonString.utf8)
          let decoder = JSONDecoder()
          self.nutritionInfo = try decoder.decode(NutritionInfo.self, from: jsonData)
        } else {
          throw "No text in response"
        }
      } catch {
        self.errorMessage = error.localizedDescription
        print("Error processing image: \(error.localizedDescription)")
      }
      self.isLoading = false
    }
  }
}

extension String: LocalizedError {}
