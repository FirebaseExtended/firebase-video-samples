package com.google.firebase.example.friendlymeals.data.repository

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.datasource.AIRemoteDataSource
import javax.inject.Inject

class AIRepository @Inject constructor(
    private val aiRemoteDataSource: AIRemoteDataSource
) {
    suspend fun generateIngredients(image: Bitmap): String {
        return aiRemoteDataSource.generateIngredients(image)
    }

    suspend fun generateRecipe(ingredients: String, notes: String): String {
        return aiRemoteDataSource.generateRecipe(ingredients, notes)
    }

    suspend fun generateRecipeImage(recipe: String): Bitmap {
        return aiRemoteDataSource.generateRecipeImage(recipe)
    }
}