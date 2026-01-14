//
// FriendlyMeals
//
// Copyright © 2026 Google LLC.
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

import FirebaseStorage
import SwiftUI

class RecipeImageStore {

  private let storage: Storage

  init(storage: Storage = Storage.storage()) {
    self.storage = storage
  }

  func saveImage(_ image: UIImage, named name: String? = nil) async throws -> URL {
    let fileName = name ?? UUID().uuidString
    let reference = storage.reference().child("images/\(fileName).jpg")
    guard let data = image.jpegData(compressionQuality: 0.9) else {
      throw NSError(domain: "FIRSampleAppErrorDomain",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to create jpg from image: \(image)"])
    }

    let _ = try await reference.putDataAsync(data)
    let url = try await reference.downloadURL()
    return url
  }

}
