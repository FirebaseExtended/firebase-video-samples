package com.google.firebase.example.friendlymeals.data.repository

import com.google.firebase.example.friendlymeals.data.datasource.DatabaseRemoteDataSource
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Review
import com.google.firebase.example.friendlymeals.data.model.Save
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.data.model.User
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListItem
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterOptions
import javax.inject.Inject

class DatabaseRepository @Inject constructor(
    private val databaseRemoteDataSource: DatabaseRemoteDataSource
) {
    suspend fun addUser(user: User) {
        databaseRemoteDataSource.addUser(user)
    }

    suspend fun addRecipe(recipe: Recipe): String {
        return databaseRemoteDataSource.addRecipe(recipe)
    }

    suspend fun getRecipe(recipeId: String): Recipe {
        return databaseRemoteDataSource.getRecipe(recipeId)
    }

    suspend fun getAllRecipes(): List<RecipeListItem> {
        return databaseRemoteDataSource.getAllRecipes()
    }

    suspend fun addTags(tagNames: List<String>) {
        return databaseRemoteDataSource.addTags(tagNames)
    }

    suspend fun getPopularTags(): List<Tag> {
        return databaseRemoteDataSource.getPopularTags()
    }

    suspend fun setReview(review: Review) {
        databaseRemoteDataSource.setReview(review)
    }

    suspend fun getRating(userId: String, recipeId: String): Int {
        return databaseRemoteDataSource.getRating(userId, recipeId)
    }

    suspend fun setFavorite(save: Save) {
        databaseRemoteDataSource.setFavorite(save)
    }

    suspend fun removeFavorite(save: Save) {
        databaseRemoteDataSource.removeFavorite(save)
    }

    suspend fun getFavorite(userId: String, recipeId: String): Boolean {
        return databaseRemoteDataSource.getFavorite(userId, recipeId)
    }

    suspend fun getFilteredRecipes(
        filterOptions: FilterOptions,
        userId: String
    ): List<RecipeListItem> {
        return databaseRemoteDataSource.getFilteredRecipes(filterOptions, userId)
    }
}