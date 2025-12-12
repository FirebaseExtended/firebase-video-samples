package com.google.firebase.example.friendlymeals.data.repository

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.datasource.AIRemoteDataSource
import com.google.firebase.example.friendlymeals.data.schema.MealSchema
import com.google.firebase.example.friendlymeals.data.schema.RecipeSchema
import javax.inject.Inject

class AIRepository @Inject constructor(
    private val aiRemoteDataSource: AIRemoteDataSource
) {
    suspend fun generateIngredients(image: Bitmap): String {
        return aiRemoteDataSource.generateIngredients(image)
    }

    suspend fun generateRecipe(ingredients: String, notes: String): RecipeSchema {
        return aiRemoteDataSource.generateRecipe(ingredients, notes)
    }

    suspend fun generateRecipePhoto(recipeTitle: String): Bitmap? {
        return aiRemoteDataSource.generateRecipePhoto(recipeTitle)
    }

    suspend fun generateRecipePhotoImagen(recipeTitle: String): Bitmap? {
        return aiRemoteDataSource.generateRecipePhotoImagen(recipeTitle)
    }

    suspend fun scanMeal(image: Bitmap): MealSchema {
        return aiRemoteDataSource.scanMeal(image)
    }
}