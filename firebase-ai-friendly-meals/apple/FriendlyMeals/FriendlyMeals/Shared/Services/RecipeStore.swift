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
import FirebaseAuth

enum RecipeStoreError: Error {
  case missingRecipeID
}

@Observable
class RecipeStore {
  private let db = Firestore.firestore(database: "default")

  private(set) var filterConfiguration: FilterConfiguration? = nil

  private static let recipeCollection = "recipes"
  private static let savesCollection = "save"

  @MainActor private(set) var topTags: [String] = []
  @MainActor private(set) var recipes = [Recipe]()

  // A list of just recipe IDs, for faster lookup.
  @MainActor private(set) var saves = Set<String>()

  private static func defaultFilter(_ store: Firestore) -> Pipeline {
    return store.pipeline().collection(recipeCollection)
  }

  private var activeQuery: Pipeline {
    let filter = activeFilters ?? RecipeStore.defaultFilter
    return filter(db)
  }

  private var activeFilters: ((Firestore) -> Pipeline)?

  private func applyConfiguration(_ configuration: FilterConfiguration,
                                  to pipeline: Pipeline,
                                  currentUserID: String? = Auth.auth().currentUser?.uid) -> Pipeline {
    var filters = pipeline
    if let id = currentUserID, configuration.shouldShowOnlyOwnRecipes {
      filters = filters.where(Field("authorId").equal(id))
    }

    if !configuration.recipeTitle.isEmpty {
      filters = filters.where(Field("title").like("%\(configuration.recipeTitle)%"))
    }

    if configuration.minimumRating > 0 {
      filters = filters.where(Field("averageRating").greaterThanOrEqual(configuration.minimumRating))
    }

    if !configuration.selectedTags.isEmpty {
      filters = filters.where(Field("tags").arrayContainsAny(Array(configuration.selectedTags)))
    }

    switch configuration.sortOption {
    case .alphabetical:
      filters = filters.sort([Field("title").ascending()])
    case .rating:
      filters = filters.sort([Field("averageRating").descending()])
    case .popularity:
      filters = filters.sort([Field("saves").descending()])
    case .none:
      break
    @unknown default:
      break
    }

    return filters
  }

  func applyConfiguration(_ configuration: FilterConfiguration) {
    filterConfiguration = configuration
    let output = { (store: Firestore) -> Pipeline in
      return self.applyConfiguration(configuration, to: store.pipeline().collection(RecipeStore.recipeCollection))
    }
    activeFilters = output
  }

  func add(_ recipe: Recipe) async throws {
    let collection = db.collection(RecipeStore.recipeCollection)
    try collection.addDocument(from: recipe)
  }
  
  func fetchRecipes(withUserID userID: String? = Auth.auth().currentUser?.uid) async throws {
    let query = activeQuery

    let snapshot = try await query.execute()
    self.recipes = snapshot.results.compactMap { result in
      let imageURL = result.data["imageUri"] as? String

      guard let title = result.data["title"] as? String,
        let instructions = result.data["instructions"] as? String,
        let ingredients = result.data["ingredients"] as? [String],
        let authorID = result.data["authorId"] as? String,
        let tags = result.data["tags"] as? [String],
        let averageRating = result.data["averageRating"] as? Double,
        let prepTime = result.data["prepTime"] as? String,
        let cookTime = result.data["cookTime"] as? String,
        let servings = result.data["servings"] as? String,
        let documentID = result.id else {
        print("Unable to initialize recipes from data: \(result.data)")
        return nil
      }

      var recipe = Recipe(
        title: title,
        instructions: instructions,
        ingredients: ingredients,
        authorId: authorID,
        tags: tags,
        averageRating: averageRating,
        imageUri: imageURL,
        prepTime: prepTime,
        cookTime: cookTime,
        servings: servings
      )

      recipe.id = documentID
      return recipe
    }

    if let id = userID {
      let saves = try await fetchSaves(forUserID: id).map { $0.recipeId }
      self.saves = Set(saves)
    }
  }

  @discardableResult
  func fetchPopularTags() async throws -> [String] {
    let snapshot = try await db.pipeline()
      .collection(RecipeStore.recipeCollection)
      .select([Field("tags")])
      .unnest(Field("tags").as("tagName"))
      .aggregate(
        [
          CountAll().as("tagCount")
        ], groups: [Field("tagName")]
      )
      .sort([Field("tagCount").descending()])
      .limit(10)
      .execute()

    let results = snapshot.results.compactMap { result in
      return result.data["tagName"] as? String
    }
    topTags = results
    return results
  }

  func delete(_ recipe: Recipe) async throws {
    guard let id = recipe.id else {
      throw RecipeStoreError.missingRecipeID
    }
    let docRef = db.collection(RecipeStore.recipeCollection).document(id)
    try await docRef.delete()
  }

  func update(_ recipe: Recipe) async throws {
    guard let id = recipe.id else {
      throw RecipeStoreError.missingRecipeID
    }
    let docRef = db.collection(RecipeStore.recipeCollection).document(id)
    try docRef.setData(from: recipe, mergeFields: ["isFavorite"])
  }
}

// Favorites/Saves
extension RecipeStore {

  func fetchSave(for recipeID: String, userID: String) async throws -> RecipeSave? {
    let documentID = RecipeSave(userID: userID, recipeID: recipeID).compositeID
    let snapshot = try await db.collection(RecipeStore.savesCollection).document(documentID).getDocument()
    if snapshot.data()?.isEmpty ?? false {
      return nil
    }

    let save = try snapshot.data(as: RecipeSave.self)
    return save
  }

  func addSave(_ save: RecipeSave) throws {
    try db.collection(RecipeStore.savesCollection).document(save.compositeID).setData(from: save)
    saves.insert(save.recipeId)
  }

  func removeSave(_ save: RecipeSave) {
    db.collection(RecipeStore.savesCollection).document(save.compositeID).delete()
    saves.remove(save.recipeId)
  }

  func fetchSaves(forUserID userID: String) async throws -> [RecipeSave] {
    let snapshot = try await db.pipeline().collection(RecipeStore.savesCollection)
      .where(Field("userId").equal(userID))
      .execute()
    let saves = try snapshot.results.map { result in
      guard let userID = result.data["userId"] as? String,
            let recipeID = result.data["recipeId"] as? String else {
        let error = NSError(domain: "FIRAuthSampleErrorDomain",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "Could not decode RecipeSave from Firestore document: \(result)"])
        throw error
      }
      return RecipeSave(userID: userID, recipeID: recipeID)
    }
    print(saves)
    return saves
  }

  func isSaved(_ recipe: Recipe) -> Bool {
    return recipe.id.flatMap {
      return saves.contains($0)
    } ?? false
  }

}
