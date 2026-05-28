import Foundation
import FirebaseAILogic

@MainActor
class AITaskService {
  private let model: GenerativeModel
  
  init() {
    // 1. Define schema for a JSON array of strings
    let responseSchema = Schema.array(
      items: .string(description: "A single actionable, independent, top-level task to be done")
    )
    
    let config = GenerationConfig(
      responseMIMEType: "application/json",
      responseSchema: responseSchema
    )
    
    // 2. Initialize Firebase AI Logic with the Google AI Developer API backend
    let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    
    // 3. Instantiate with the latest modern model: gemini-2.5-flash
    self.model = ai.generativeModel(
      modelName: "gemini-2.5-flash",
      generationConfig: config
    )
  }
  
  func breakDownTask(title: String) async throws -> [String] {
    let prompt = """
    Break down the following complex task into exactly 4-6 simple, actionable, and concrete top-level tasks.
    
    Task: "\(title)"
    """
    
    let response = try await model.generateContent(prompt)
    guard let responseText = response.text else {
      throw NSError(domain: "AITaskService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No response from AI"])
    }
    
    guard let data = responseText.data(using: .utf8) else { return [] }
    return try JSONDecoder().decode([String].self, from: data)
  }
}
