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
  @DocumentID var id: String?
  
  var title: String
  var description: String
  var cookingTime: Int
  var ingredients: [Ingredient]
  var instructions: [String]
  var isFavorite: Bool = false
  
  var userId: String?
}

extension Recipe {
  init(from representable: RecipeRepresentable) {
    self.init(
      title: representable.title,
      description: representable.description,
      cookingTime: representable.cookingTime,
      ingredients: representable.ingredients,
      instructions: representable.instructions
    )
  }
}
