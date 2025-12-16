package com.google.firebase.example.friendlymeals.data.datasource

import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Review
import com.google.firebase.example.friendlymeals.data.model.Save
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.data.model.User
import com.google.firebase.firestore.AggregateField
import com.google.firebase.firestore.AggregateSource
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query.Direction.DESCENDING
import com.google.firebase.firestore.SetOptions
import com.google.firebase.firestore.toObject
import kotlinx.coroutines.tasks.await
import java.util.Locale
import javax.inject.Inject

class DatabaseRemoteDataSource @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    fun addUser(user: User) {
        firestore.collection(USER_COLLECTION).add(user)
    }

    suspend fun addRecipe(recipe: Recipe): String {
        val recipeRef = firestore.collection(RECIPE_COLLECTION).document()
        val finalRecipe = recipe.copy(id = recipeRef.id)
        recipeRef.set(finalRecipe).await()
        return recipeRef.id
    }

    suspend fun getRecipe(recipeId: String): Recipe? {
        return firestore
            .collection(RECIPE_COLLECTION)
            .document(recipeId)
            .get().await().toObject()
    }

    suspend fun getAverageRatingForRecipe(recipeId: String): Double {
        val collection = firestore.collection(RECIPE_COLLECTION)
            .document(recipeId)
            .collection(REVIEW_SUBCOLLECTION)

        val snapshot = collection.aggregate(AggregateField.average(RATING_FIELD))
            .get(AggregateSource.SERVER)
            .await()

        return snapshot.get(AggregateField.average(RATING_FIELD)) ?: 0.0
    }

    suspend fun addTags(tagNames: List<String>) {
        val normalizedTags = tagNames
            .map { it.trim().lowercase(Locale.getDefault()) }
            .distinct()

        val batch = firestore.batch()
        val tagsCollection = firestore.collection(TAG_COLLECTION)

        normalizedTags.forEach { tagName ->
            val tagRef = tagsCollection.document(tagName)

            val data = hashMapOf(
                "name" to tagName,
                "totalRecipes" to FieldValue.increment(1)
            )

            batch.set(tagRef, data, SetOptions.merge())
        }

        batch.commit().await()
    }

    suspend fun getPopularTags(): List<Tag> {
        return firestore.collection(TAG_COLLECTION)
            .orderBy(TOTAL_RECIPES_FIELD, DESCENDING)
            .limit(5)
            .get()
            .await()
            .toObjects(Tag::class.java)
    }

    suspend fun setReview(review: Review) {
        val reviewRef = firestore.collection(RECIPE_COLLECTION)
            .document(review.recipeId)
            .collection(REVIEW_SUBCOLLECTION)
            .document(review.userId)

        reviewRef.set(review).await()
    }

    suspend fun getReview(userId: String, recipeId: String): Int {
        val document = firestore.collection(RECIPE_COLLECTION)
            .document(recipeId)
            .collection(REVIEW_SUBCOLLECTION)
            .document(userId)
            .get()
            .await()
            .toObject<Review>()

        return document?.rating ?: 0
    }

    suspend fun setFavorite(save: Save) {
        val saveRef = firestore
            .collection(SAVE_COLLECTION)
            .document("${save.recipeId}_${save.userId}")

        saveRef.set(save).await()
    }

    suspend fun getFavorite(userId: String, recipeId: String): Boolean {
        val document = firestore.collection(SAVE_COLLECTION)
            .document("${recipeId}_${userId}")
            .get()
            .await()
            .toObject<Save>()

        return document?.isFavorite ?: false
    }

    companion object {
        private const val USER_COLLECTION = "user"
        private const val RECIPE_COLLECTION = "recipe"
        private const val TAG_COLLECTION = "tag"
        private const val SAVE_COLLECTION = "save"
        private const val REVIEW_SUBCOLLECTION = "review"
        private const val RATING_FIELD = "rating"
        private const val TOTAL_RECIPES_FIELD = "totalRecipes"
    }
}