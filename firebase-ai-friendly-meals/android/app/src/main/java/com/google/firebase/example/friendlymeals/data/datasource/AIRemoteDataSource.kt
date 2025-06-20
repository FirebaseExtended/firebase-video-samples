package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import com.google.firebase.ai.GenerativeModel
import com.google.firebase.ai.ImagenModel
import com.google.firebase.ai.type.PublicPreviewAPI
import com.google.firebase.ai.type.content
import javax.inject.Inject
import androidx.core.graphics.createBitmap

@OptIn(PublicPreviewAPI::class)
class AIRemoteDataSource @Inject constructor(
    private val generativeModel: GenerativeModel,
    private val imagenModel: ImagenModel,
) {
    suspend fun generateIngredients(image: Bitmap): String {
        //TODO: call generative model with multimodal prompt to extract ingredients from image
        return ""
    }

    suspend fun generateRecipe(ingredients: String, notes: String): String {
        //TODO: call generative model to generate recipe
        return ""
    }

    @OptIn(PublicPreviewAPI::class)
    suspend fun generateRecipeImage(recipe: String): Bitmap {
        //TODO: call Imagen model to generate recipe photo
        return createBitmap(1, 1)
    }
}