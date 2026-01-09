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

import FirebaseAuth

struct RecipeSave: Codable, Hashable {

  var userId: String
  var recipeId: String

  var compositeID: String {
    return "\(recipeId)_\(userId)"
  }

  init(userID: String, recipeID: String) {
    self.userId = userID
    self.recipeId = recipeID
  }
}

extension RecipeSave {

  init?(recipeID: String, user: User? = Auth.auth().currentUser) {
    guard let id = user?.uid else { return nil }
    self.init(userID: id, recipeID: recipeID)
  }

}
