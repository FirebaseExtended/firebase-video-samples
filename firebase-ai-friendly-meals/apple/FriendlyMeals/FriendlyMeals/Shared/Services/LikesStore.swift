//
//  LikesStore.swift
//  FriendlyMeals
//
//  Created by Morgan Chen on 1/14/26.
//

import FirebaseAuth
import FirebaseFirestore

@Observable
class LikesStore {

  private let db = Firestore.firestore(database: "default")

  // A list of just recipe IDs, for faster lookup.
  @MainActor private(set) var likes = Set<String>()

  private static let likesCollection = "likes"

  func fetchLike(for recipeID: String, userID: String) async throws -> RecipeLike? {
    let documentID = RecipeLike(userID: userID, recipeID: recipeID).compositeID
    let snapshot = try await db.collection(LikesStore.likesCollection).document(documentID).getDocument()
    if snapshot.data()?.isEmpty ?? false {
      return nil
    }

    let like = try snapshot.data(as: RecipeLike.self)
    return like
  }

  func addLike(_ like: RecipeLike) throws {
    try db.collection(LikesStore.likesCollection).document(like.compositeID).setData(from: like)
    likes.insert(like.recipeId)
  }

  func removeLike(_ like: RecipeLike) {
    db.collection(LikesStore.likesCollection).document(like.compositeID).delete()
    likes.remove(like.recipeId)
  }

  @discardableResult
  func fetchLikesForDefaultUser() async throws -> [RecipeLike] {
    if let defaultUserID = Auth.auth().currentUser?.uid {
      return try await fetchLikes(forUserID: defaultUserID)
    }
    return []
  }

  @discardableResult
  func fetchLikes(forUserID userID: String) async throws -> [RecipeLike] {
    let snapshot = try await db.pipeline().collection(LikesStore.likesCollection)
      .where(Field("userId").equal(userID))
      .execute()
    let likes = try snapshot.results.map { result in
      guard let userID = result.data["userId"] as? String,
            let recipeID = result.data["recipeId"] as? String else {
        let errorMessage = "Could not decode RecipeLike from Firestore document: \(result)"
        throw RecipeStoreError.likeDecodingError(errorMessage)
      }
      return RecipeLike(userID: userID, recipeID: recipeID)
    }
    self.likes = Set(likes.map(\.recipeId))
    return likes
  }

  func isLiked(_ recipe: Recipe) -> Bool {
    return recipe.id.flatMap {
      return likes.contains($0)
    } ?? false
  }

  func toggleLike(recipe: Recipe) async throws {
    guard let like = recipe.id.flatMap({ RecipeLike(recipeID: $0) }) else {
      return
    }
    if isLiked(recipe) {
      removeLike(like)
    } else {
      try addLike(like)
    }
  }

}
