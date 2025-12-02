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
import Observation
import FirebaseFirestore

enum RecipeStoreError: Error {
  case missingRecipeID
}

@Observable
class RecipeStore {
  private let db = Firestore.firestore()
  private let collectionName = "recipes"
  private var listener: ListenerRegistration?

  var recipes = [Recipe]()

  func add(_ recipe: Recipe) async throws {
    let collection = db.collection(collectionName)
    try collection.addDocument(from: recipe)
  }
  
  func fetchRecipes() {
    listener?.remove()
    let query = db.collection(collectionName).order(by: "title")
    self.listener = query.addSnapshotListener { snapshot, error in
      if let error {
        print("Error fetching recipes: \(error)")
        return
      }

      guard let snapshot else {
        print("No recipes found")
        return
      }

      self.recipes = snapshot.documents.compactMap { document in
        do {
          return try document.data(as: Recipe.self)
        } catch {
          print("Failed to decode recipe with ID \(document.documentID): \(error)")
          return nil
        }
      }
    }
  }

  func delete(_ recipe: Recipe) async throws {
    guard let id = recipe.id else {
      throw RecipeStoreError.missingRecipeID
    }
    let docRef = db.collection(collectionName).document(id)
    try await docRef.delete()
  }

  func update(_ recipe: Recipe) async throws {
    guard let id = recipe.id else {
      throw RecipeStoreError.missingRecipeID
    }
    let docRef = db.collection(collectionName).document(id)
    try docRef.setData(from: recipe, mergeFields: ["isFavorite"])
  }
}
