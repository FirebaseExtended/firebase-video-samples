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

/// Represents a recipe generated from Gemini.
/// Don't add any user state to this struct or it will fail to properly decode from
/// Gemini-generated JSON.
struct GeneratedRecipe: Decodable, RecipeRepresentable {

  var title: String
  var instructions: String
  var ingredients: [String]

  // These are plain strings
  var tags: [String]

  var imageUri: String?

  // These are display strings
  var prepTime: String
  var cookTime: String
  var servings: String

}
