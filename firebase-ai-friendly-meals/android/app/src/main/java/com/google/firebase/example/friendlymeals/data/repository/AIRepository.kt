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

    suspend fun generateRecipePhoto(recipe: String): Bitmap? {
        return aiRemoteDataSource.generateRecipePhoto(recipe)
    }

    suspend fun generateRecipePhotoImagen(recipe: String): Bitmap? {
        return aiRemoteDataSource.generateRecipePhotoImagen(recipe)
    }

    suspend fun scanMeal(image: Bitmap): MealSchema {
        return aiRemoteDataSource.scanMeal(image)
    }
}