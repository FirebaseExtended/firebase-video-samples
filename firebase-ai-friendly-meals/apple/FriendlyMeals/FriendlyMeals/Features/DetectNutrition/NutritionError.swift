import Foundation

enum NutritionError: Error, LocalizedError {
  case modelNotConfigured
  case noTextInResponse
  case responseDecodingFailed(Error?)

  var errorDescription: String? {
    switch self {
    case .modelNotConfigured:
      return "The generative model is not configured."
    case .noTextInResponse:
      return "The model did not return any text in its response."
    case .responseDecodingFailed(let underlyingError):
      if let error = underlyingError {
        return "Failed to decode the nutrition information from the model's response: \(error.localizedDescription)"
      }
      return "Failed to decode the nutrition information from the model's response."
    }
  }
}
