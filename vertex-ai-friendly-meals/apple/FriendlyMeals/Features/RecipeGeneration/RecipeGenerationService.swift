import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseVertexAI
import FirebaseFunctions
import UIKit

class RecipeGenerationService {
  private let vertexAI = VertexAI.vertexAI()
  private let functions = Functions.functions()

  private struct RecipeResponse: Codable, Sendable {
    let title: String
    let description: String
    let imageURL: String
    let cookingTimeInMinutes: Int
    let ingredientsList: [String]
    let instructions: [String]
    let cuisine: String
  }

  private struct GenerateRecipeRequest: Codable, Sendable {
    let image: String
    let cuisine: String
    let mealType: String
    let servings: Int
    let dietaryRestrictions: [String]?
  }

  private struct ImageBasedRecipeResponse: Codable, Sendable {
    let recipes: [RecipeResponse]
  }

  private lazy var recipeSchema = Schema.object(
    properties: [
      "title": .string(),
      "description": .string(),
      "imageURL": .string(),
      "cookingTimeInMinutes": .integer(), 
      "ingredients": .array(items: .string()),
      "instructions": .array(items: .string()),
      "cuisine": .string()
    ]
  )

  private lazy var model = vertexAI.generativeModel(
    modelName: "gemini-2.0-flash",
    generationConfig: GenerationConfig(
      responseMIMEType: "application/json",
      responseSchema: recipeSchema
    )
  )

  private lazy var imagenModel = vertexAI.imagenModel(
    modelName: "imagen-3.0-generate-002",
    generationConfig: ImagenGenerationConfig(numberOfImages: 1)
  )

  private lazy var visionModel = vertexAI.generativeModel(
    modelName: "gemini-2.0-flash",
    generationConfig: GenerationConfig()
  )

  func generateRecipe(from ingredients: String,
                      cuisine: Cuisine,
                      mealType: MealType,
                      servings: Int) async throws -> Recipe {
    let prompt = """
    Create a \(cuisine.rawValue) \(mealType.rawValue.lowercased()) recipe for \(servings) people using these ingredients: \(ingredients).
    Generate:
    1. A creative title that describes the dish
    2. A brief, appetizing description
    3. Estimated cooking time in minutes
    4. List of ingredients with measurements
    5. Step-by-step cooking instructions
    6. Include the cuisine type ("\(cuisine.rawValue)")
    7. For the imageURL, provide a URL to a high-quality food photo from Pexels.com that most closely matches this exact \(cuisine.rawValue) dish. The image should show a finished, plated dish that matches the recipe's style and ingredients.
    """

    do {
      let response = try await model.generateContent(prompt)
      guard let jsonString = response.text,
            let jsonData = jsonString.data(using: .utf8) else {
        throw NSError(domain: "RecipeGenerationError",
                      code: -1,
                      userInfo: [NSLocalizedDescriptionKey: "No response from model"])
      }

      let decoder = JSONDecoder()
      return try decoder.decode(Recipe.self, from: jsonData)

    } catch let decodingError as DecodingError {
      throw NSError(domain: "RecipeGenerationError",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode recipe: \(decodingError)"])
    } catch {
      throw error
    }
  }

  func generateImage(for recipe: Recipe) async throws -> UIImage? {
    let prompt = """
    A professional food photography shot of \(recipe.title). \
    The dish should be \(recipe.description). \
    Style: High-end food photography, restaurant-quality plating, soft natural \
    lighting, shot from above on a clean background, showing the complete \
    plated dish. \
    Cuisine style: \(recipe.cuisine.rawValue)
    """

    let response = try await imagenModel.generateImages(prompt: prompt)

    if let filteredReason = response.filteredReason {
      throw NSError(domain: "ImageGenerationError",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Image generation filtered: \(filteredReason)"])
    }

    return response.images.first.flatMap { UIImage(data: $0.data) }
  }

  func analyzeImage(_ image: UIImage) async throws -> String {
    let prompt = """
    Please analyze this image and list all visible food ingredients. \
    Format the response as a comma-separated list of ingredients. \
    Be specific with measurements where possible, but focus on identifying the ingredients accurately.
    """

    let response = try await visionModel.generateContent(prompt, image)
    return response.text ?? ""
  }

  func generateRecipeFromImage(_ image: UIImage,
                               cuisine: Cuisine,
                               mealType: MealType,
                               servings: Int,
                               dietaryRestrictions: [String]? = nil) async throws -> Recipe {
    guard let dataUrl = image.toDataURL() else {
      throw NSError(domain: "RecipeGenerationError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])
    }

    let request = GenerateRecipeRequest(
      image: dataUrl,
      cuisine: cuisine.rawValue,
      mealType: mealType.rawValue.lowercased(),
      servings: servings,
      dietaryRestrictions: dietaryRestrictions
    )

    let generateRecipe: Callable<GenerateRecipeRequest, ImageBasedRecipeResponse> = functions.httpsCallable("generateRecipe")

    do {
      let response = try await generateRecipe.call(request)
      guard let generatedRecipe = response.recipes.first else {
        throw NSError(domain: "RecipeGenerationError",
                      code: -2,
                      userInfo: [NSLocalizedDescriptionKey: "No recipe generated"])
      }

      return Recipe(
        id: UUID(),
        title: generatedRecipe.title,
        description: generatedRecipe.description,
        cuisine: Cuisine(rawValue: generatedRecipe.cuisine) ?? cuisine,
        cookingTimeInMinutes: generatedRecipe.cookingTimeInMinutes,
        imageURL: URL(string: generatedRecipe.imageURL) ?? URL(string: "https://placeholder.com")!,
        ingredients: generatedRecipe.ingredientsList,
        instructions: generatedRecipe.instructions
      )
    } catch {
      throw NSError(domain: "RecipeGenerationError",
                    code: -3,
                    userInfo: [NSLocalizedDescriptionKey: "Function call failed: \(error.localizedDescription)"])
    }
  }
}

extension UIImage {
  func toDataURL(withCompression compression: CGFloat = 0.8) -> String? {
    guard let imageData = self.jpegData(compressionQuality: compression) else { return nil }
    let base64String = imageData.base64EncodedString()
    return "data:image/jpeg;base64,\(base64String)"
  }
}
