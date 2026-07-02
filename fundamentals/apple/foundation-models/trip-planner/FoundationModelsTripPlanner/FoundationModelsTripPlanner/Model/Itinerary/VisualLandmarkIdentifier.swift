import Foundation
import FoundationModels
import FirebaseAILogic
import UIKit

@MainActor
final class VisualLandmarkIdentifier {
    private let session: LanguageModelSession
    
    init() {
      let model = FirebaseAI.firebaseAI().geminiLanguageModel(name: "gemini-3.1-flash-lite")
      self.session = LanguageModelSession(
          model: model,
          instructions: Instructions {
              "You are a visual landmark identifier."
          }
      )
    }
    
    func identifyLandmark(in image: UIImage) async throws -> LandmarkIdentification {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "VisualLandmarkIdentifier", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to get CGImage from UIImage"])
        }
        
        let response = try await session.respond(
            generating: LandmarkIdentification.self
        ) {
            Attachment(cgImage)
            "Identify the landmark in this image and provide a short description."
        }
        
        return response.content
    }
}
