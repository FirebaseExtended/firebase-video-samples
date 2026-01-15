package com.google.firebase.example.friendlymeals.data.datasource

import android.util.Log
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Review
import com.google.firebase.example.friendlymeals.data.model.Save
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.data.model.User
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListItem
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterOptions
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.PipelineResult
import com.google.firebase.firestore.pipeline.Expression.Companion.field
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import kotlin.collections.first
import kotlin.collections.mapNotNull

class DatabaseRemoteDataSource @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    suspend fun addUser(user: User) {
        firestore.collection(USERS_COLLECTION).add(user).await()
    }

    suspend fun addRecipe(recipe: Recipe): String {
        return ""
    }

    suspend fun getRecipe(recipeId: String): Recipe {
        return Recipe()
    }

    suspend fun getAllRecipes(): List<RecipeListItem> {
        return listOf()
    }

    suspend fun addTags(tagNames: List<String>) {

    }

    suspend fun getPopularTags(): List<Tag> {
        val results = firestore.pipeline()
            .collection(TAGS_COLLECTION)
            .sort(field(TOTAL_RECIPES_FIELD).descending())
            .limit(10)
            .execute().await().results

        return results.mapNotNull { result ->
            val itemData = result.getData()
            val name = itemData[NAME_FIELD] as? String

            if (name.isNullOrEmpty()) {
                Log.w(this::class.java.simpleName, "Empty tag name")
                return@mapNotNull null
            }

            Tag(
                name = name,
                totalRecipes = itemData[TOTAL_RECIPES_FIELD] as? Int ?: 0
            )
        }
    }

    /*
    NOTE: The right way to do this is in a transaction via Cloud Function,
    this function is here just for demonstrating aggregate

    To enforce a "one review per user" constraint, Review documents use a deterministic ID based on
    the following pattern: "${recipeId}_${userId}". With this approach, you can retrieve a specific
    review instantly without searching the entire collection.
     */
    suspend fun setReview(review: Review) {
        val recipeRef = firestore
            .collection(RECIPES_COLLECTION)
            .document(review.recipeId)

        val reviewRef = recipeRef
            .collection(REVIEWS_SUBCOLLECTION)
            .document("${review.recipeId}_${review.userId}")

        reviewRef.set(review).await()

        val newAvg = getAverageRatingForRecipe(review.recipeId)
        recipeRef.update(AVERAGE_RATING_FIELD, newAvg).await()
    }

    private suspend fun getAverageRatingForRecipe(recipeId: String): Double {
        return 0.0
    }

    suspend fun getRating(userId: String, recipeId: String): Int {
        val reviewId = "${recipeId}_${userId}"
        val reviewPath = "${RECIPES_COLLECTION}/${recipeId}/${REVIEWS_SUBCOLLECTION}/${reviewId}"

        val results = firestore
            .pipeline()
            .documents(reviewPath)
            .execute().await().results

        if (results.isEmpty()) return 0

        val reviewData = results.first().getData()

        return (reviewData[RATING_FIELD] as? Number)?.toInt() ?: 0
    }

    /*
    To enforce a "one favorite per user" constraint, Like documents use a deterministic ID based on
    the following pattern: "${recipeId}_${userId}". With this approach, you can retrieve a specific
    Like document instantly without searching the entire collection.
     */
    suspend fun setFavorite(save: Save) {
        val saveRef = firestore
            .collection(LIKES_COLLECTION)
            .document("${save.recipeId}_${save.userId}")

        saveRef.set(save).await()

        firestore
            .collection(RECIPES_COLLECTION)
            .document(save.recipeId)
            .update(SAVES_FIELD, FieldValue.increment(1))
            .await()
    }

    suspend fun removeFavorite(save: Save) {
        firestore
            .collection(LIKES_COLLECTION)
            .document("${save.recipeId}_${save.userId}")
            .delete()
            .await()

        firestore
            .collection(RECIPES_COLLECTION)
            .document(save.recipeId)
            .update(SAVES_FIELD, FieldValue.increment(-1))
            .await()
    }

    suspend fun getFavorite(userId: String, recipeId: String): Boolean {
        val favoriteId = "${recipeId}_${userId}"
        val favoritePath = "${LIKES_COLLECTION}/${favoriteId}"

        return firestore
            .pipeline()
            .documents(favoritePath)
            .execute().await().results.isNotEmpty()
    }

    suspend fun getFilteredRecipes(
        filterOptions: FilterOptions,
        userId: String
    ): List<RecipeListItem> {
        return listOf()
    }

    private fun List<PipelineResult>.toRecipe(): Recipe {
        val itemData = this.first().getData()

        return Recipe(
            id = itemData[ID_FIELD] as? String ?: "",
            title = itemData[TITLE_FIELD] as? String ?: "",
            instructions = itemData[INSTRUCTIONS_FIELD] as? String ?: "",
            ingredients = (itemData[INGREDIENTS_FIELD] as? List<*>)?.filterIsInstance<String>() ?: listOf(),
            authorId = itemData[AUTHOR_ID_FIELD] as? String ?: "",
            tags = (itemData[TAGS_FIELD] as? List<*>)?.filterIsInstance<String>() ?: listOf(),
            averageRating = (itemData[AVERAGE_RATING_FIELD] as? Number)?.toDouble() ?: 0.0,
            saves = (itemData[SAVES_FIELD] as? Number)?.toInt() ?: 0,
            prepTime = itemData[PREP_TIME_FIELD] as? String ?: "",
            cookTime = itemData[COOK_TIME_FIELD] as? String ?: "",
            servings = itemData[SERVINGS_FIELD] as? String ?: "",
            imageUri = itemData[IMAGE_URI_FIELD] as? String
        )
    }

    private fun List<PipelineResult>.toRecipeListItem(): List<RecipeListItem> {
        return this.mapNotNull { result ->
            val itemData = result.getData()
            val id = itemData[ID_FIELD] as? String

            if (id.isNullOrEmpty()) {
                Log.w(this::class.java.simpleName, "Empty ID for item $itemData")
                return@mapNotNull null
            }

            RecipeListItem(
                id = id,
                title = itemData[TITLE_FIELD] as? String ?: "",
                averageRating = itemData[AVERAGE_RATING_FIELD] as? Double ?: 0.0,
                imageUri = itemData[IMAGE_URI_FIELD] as? String
            )
        }
    }

    companion object {
        //Collections
        private const val USERS_COLLECTION = "users"
        private const val RECIPES_COLLECTION = "recipes"
        private const val TAGS_COLLECTION = "tags"
        private const val LIKES_COLLECTION = "likes"
        private const val REVIEWS_SUBCOLLECTION = "reviews"

        //Fields
        private const val ID_FIELD = "id"
        private const val RATING_FIELD = "rating"
        private const val NAME_FIELD = "name"
        private const val TOTAL_RECIPES_FIELD = "totalRecipes"
        private const val AVERAGE_RATING_FIELD = "averageRating"
        private const val AUTHOR_ID_FIELD = "authorId"
        private const val TITLE_FIELD = "title"
        private const val TAGS_FIELD = "tags"
        private const val SAVES_FIELD = "saves"
        private const val IMAGE_URI_FIELD = "imageUri"
        private const val PREP_TIME_FIELD = "prepTime"
        private const val COOK_TIME_FIELD = "cookTime"
        private const val SERVINGS_FIELD = "servings"
        private const val INSTRUCTIONS_FIELD = "instructions"
        private const val INGREDIENTS_FIELD = "ingredients"

        //Field aliases
        private const val AVG_RATING_ALIAS = "avg_rating"
    }
}