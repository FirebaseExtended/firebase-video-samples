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
