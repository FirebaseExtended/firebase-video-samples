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
import FirebaseFirestore

struct Recipe: Codable, Identifiable, Hashable, RecipeRepresentable {
  // Used for list rendering
  @DocumentID var id: String?

  var title: String
  var instructions: String
  var ingredients: [String]
  var authorId: String

  // These are plain strings
  var tags: [String]

  var averageRating: Double
  var imageUri: String?

  // These are display strings
  var prepTime: String
  var cookTime: String
  var servings: String

  // TODO: implement favorites
  var isFavorite: Bool {
    return false
  }

}

extension Recipe {
  init(from representable: RecipeRepresentable, authorID: String?) {
    self.init(
      title: representable.title,
      instructions: representable.instructions,
      ingredients: representable.ingredients,
      authorId: authorID ?? "anonymous",
      tags: representable.tags,
      averageRating: 0,
      imageUri: representable.imageUri,
      prepTime: representable.prepTime,
      cookTime: representable.cookTime,
      servings: representable.servings
    )
  }
}
