package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import com.google.firebase.vertexai.GenerativeModel
import com.google.firebase.vertexai.ImagenModel
import com.google.firebase.vertexai.type.PublicPreviewAPI
import javax.inject.Inject

@OptIn(PublicPreviewAPI::class)
class AIRemoteDataSource @Inject constructor(
    private val generativeModel: GenerativeModel,
    private val imagenModel: ImagenModel,
) {
    suspend fun generateRecipe(ingredients: String, notes: String): String {
        //TODO: Call Gemini API to generate recipe based on ingredients and notes
        return ""
    }

    @OptIn(PublicPreviewAPI::class)
    suspend fun generateRecipeImage(recipe: String): Bitmap {
        //TODO: call Imagen API to generate recipe image based on recipe returned by Gemini
        return Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
    }
}