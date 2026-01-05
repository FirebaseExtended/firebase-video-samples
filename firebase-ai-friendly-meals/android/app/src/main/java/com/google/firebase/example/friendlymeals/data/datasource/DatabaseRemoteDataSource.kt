package com.google.firebase.example.friendlymeals.data.datasource

import android.util.Log
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Review
import com.google.firebase.example.friendlymeals.data.model.Save
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.data.model.User
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListItem
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterOptions
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.SortByFilter
import com.google.firebase.firestore.AggregateField
import com.google.firebase.firestore.AggregateSource
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.PipelineResult
import com.google.firebase.firestore.SetOptions
import com.google.firebase.firestore.pipeline.Expression.Companion.field
import com.google.firebase.firestore.toObject
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import kotlin.collections.first
import kotlin.collections.mapNotNull

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

    suspend fun getRecipe(recipeId: String): Recipe {
        return firestore.pipeline().documents(
            firestore
                .collection(RECIPE_COLLECTION)
                .document(recipeId)
        ).execute().await().results.toRecipe()
    }

    suspend fun getAllRecipes(): List<RecipeListItem> {
        return firestore
            .pipeline()
            .collection(RECIPE_COLLECTION)
            .execute().await().results.toRecipeListItem()
    }

    suspend fun addTags(tagNames: List<String>) {
        val normalizedTags = tagNames
            .map { it.trim() }
            .distinct()

        val batch = firestore.batch()
        val tagsCollection = firestore.collection(TAG_COLLECTION)

        normalizedTags.forEach { tagName ->
            val tagRef = tagsCollection.document(tagName)

            val data = hashMapOf(
                NAME_FIELD to tagName,
                TOTAL_RECIPES_FIELD to FieldValue.increment(1)
            )

            batch.set(tagRef, data, SetOptions.merge())
        }

        batch.commit().await()
    }

    suspend fun getPopularTags(): List<Tag> {
        val results = firestore.pipeline()
            .collection(TAG_COLLECTION)
            .sort(field(TOTAL_RECIPES_FIELD).descending())
            .limit(10)
            .execute().await().results

        return results.mapNotNull { result ->
            val itemData = result.getData()
            val name = itemData["name"] as? String

            if (name.isNullOrEmpty()) {
                Log.w(this::class.java.simpleName, "Empty tag name")
                return@mapNotNull null
            }

            Tag(
                name = name,
                totalRecipes = itemData["totalRecipes"] as? Int ?: 0
            )
        }
    }

    /*
    NOTE: The right way to do this is in a transaction via Cloud Function,
    this function is here just for demonstrating aggregate
     */
    suspend fun setReview(review: Review) {
        val recipeRef = firestore
            .collection(RECIPE_COLLECTION)
            .document(review.recipeId)

        val reviewRef = recipeRef
            .collection(REVIEW_SUBCOLLECTION)
            .document("${review.recipeId}_${review.userId}")

        reviewRef.set(review).await()

        val newAvg = getAverageRatingForRecipe(review.recipeId)
        recipeRef.update(AVERAGE_RATING_FIELD, newAvg).await()
    }

    private suspend fun getAverageRatingForRecipe(recipeId: String): Double {
        val collection = firestore.collection(RECIPE_COLLECTION)
            .document(recipeId)
            .collection(REVIEW_SUBCOLLECTION)

        val snapshot = collection.aggregate(AggregateField.average(RATING_FIELD))
            .get(AggregateSource.SERVER)
            .await()

        return snapshot.get(AggregateField.average(RATING_FIELD)) ?: 0.0
    }

    suspend fun getReview(userId: String, recipeId: String): Int {
        val document = firestore.collection(RECIPE_COLLECTION)
            .document(recipeId)
            .collection(REVIEW_SUBCOLLECTION)
            .document("${recipeId}_${userId}")
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

        firestore
            .collection(RECIPE_COLLECTION)
            .document(save.recipeId)
            .update(SAVES_FIELD, FieldValue.increment(1))
            .await()
    }

    suspend fun removeFavorite(save: Save) {
        firestore
            .collection(SAVE_COLLECTION)
            .document("${save.recipeId}_${save.userId}")
            .delete()
            .await()

        firestore
            .collection(RECIPE_COLLECTION)
            .document(save.recipeId)
            .update(SAVES_FIELD, FieldValue.increment(-1))
            .await()
    }

    suspend fun getFavorite(userId: String, recipeId: String): Boolean {
        val results = firestore.pipeline().documents(
            firestore
                .collection(SAVE_COLLECTION)
                .document("${recipeId}_${userId}")
        ).execute().await().results

        return results.isNotEmpty()
    }

    suspend fun getFilteredRecipes(
        filterOptions: FilterOptions,
        userId: String
    ): List<RecipeListItem> {
        var pipeline = firestore.pipeline().collection(RECIPE_COLLECTION)

        if (filterOptions.recipeTitle.isNotBlank()) {
            pipeline = pipeline
                .where(field(TITLE_FIELD).toLower()
                    .stringContains(filterOptions.recipeTitle.lowercase()))
        }

        if (filterOptions.filterByMine) {
            pipeline = pipeline
                .where(field(AUTHOR_ID_FIELD)
                    .equal(userId))
        }

        if (filterOptions.rating > 0) {
            pipeline = pipeline
                .where(field(AVERAGE_RATING_FIELD)
                    .greaterThanOrEqual(filterOptions.rating))
        }

        if (filterOptions.selectedTags.isNotEmpty()) {
            pipeline = pipeline
                .where(field(TAGS_FIELD)
                    .arrayContainsAny(filterOptions.selectedTags))
        }

        when (filterOptions.sortBy) {
            SortByFilter.RATING -> {
                pipeline = pipeline
                    .sort(field(AVERAGE_RATING_FIELD)
                        .descending())
            }
            SortByFilter.ALPHABETICAL -> {
                pipeline = pipeline
                    .sort(field(TITLE_FIELD)
                        .ascending())
            }
            SortByFilter.POPULARITY -> {
                pipeline = pipeline
                    .sort(field(SAVES_FIELD)
                        .descending())
            }
        }

        return pipeline.execute().await().results.toRecipeListItem()
    }

    private fun List<PipelineResult>.toRecipe(): Recipe {
        val itemData = this.first().getData()

        return Recipe(
            id = itemData["id"] as? String ?: "",
            title = itemData["title"] as? String ?: "",
            instructions = itemData["instructions"] as? String ?: "",
            ingredients = (itemData["ingredients"] as? List<*>)?.filterIsInstance<String>() ?: listOf(),
            authorId = itemData["authorId"] as? String ?: "",
            tags = (itemData["tags"] as? List<*>)?.filterIsInstance<String>() ?: listOf(),
            averageRating = (itemData["averageRating"] as? Number)?.toDouble() ?: 0.0,
            saves = (itemData["saves"] as? Number)?.toInt() ?: 0,
            prepTime = itemData["prepTime"] as? String ?: "",
            cookTime = itemData["cookTime"] as? String ?: "",
            servings = itemData["servings"] as? String ?: "",
            imageUri = itemData["imageUri"] as? String
        )
    }

    private fun List<PipelineResult>.toRecipeListItem(): List<RecipeListItem> {
        return this.mapNotNull { result ->
            val itemData = result.getData()
            val id = itemData["id"] as? String

            if (id.isNullOrEmpty()) {
                Log.w(this::class.java.simpleName, "Empty ID for item $itemData")
                return@mapNotNull null
            }

            RecipeListItem(
                id = id,
                title = itemData["title"] as? String ?: "",
                averageRating = itemData["averageRating"] as? Double ?: 0.0,
                imageUri = itemData["imageUri"] as? String
            )
        }
    }

    companion object {
        //Collections
        private const val USER_COLLECTION = "user"
        private const val RECIPE_COLLECTION = "recipe"
        private const val TAG_COLLECTION = "tag"
        private const val SAVE_COLLECTION = "save"
        private const val REVIEW_SUBCOLLECTION = "review"

        //Fields
        private const val RATING_FIELD = "rating"
        private const val NAME_FIELD = "name"
        private const val TOTAL_RECIPES_FIELD = "totalRecipes"
        private const val AVERAGE_RATING_FIELD = "averageRating"
        private const val AUTHOR_ID_FIELD = "authorId"
        private const val TITLE_FIELD = "title"
        private const val TAGS_FIELD = "tags"
        private const val SAVES_FIELD = "saves"
    }
}