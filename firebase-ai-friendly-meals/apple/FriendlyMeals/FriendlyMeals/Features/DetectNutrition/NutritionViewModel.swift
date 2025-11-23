import FirebaseAI
import Foundation
import SwiftUI

struct NutritionInfo: Identifiable, Codable, Equatable {
  let id = UUID()
  let detectedDish: String
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
  var currentThoughtStep: ThoughtStep? = nil

  private let model: GenerativeModel

  init() {
    let generationConfig = GenerationConfig(
      responseMIMEType: "application/json",
      responseSchema: .object(
        properties: [
          "detectedDish": .string(),
          "carbohydrates": .string(),
          "fat": .string(),
          "protein": .string(),
          "kilocalories": .string(),
        ]
      ),
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
          Identify the dish in this image and analyze its nutritional values, including carbohydrates, fat, protein, and kilocalories. Provide the detected dish name along with the nutritional information in the final structured JSON.
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
