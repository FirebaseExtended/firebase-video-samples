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
        var prompt = "Based on this ingredients list: $ingredients, please give me one recipe."
        if (notes.isNotBlank()) {
          prompt += "Please take in consideration these notes: $notes."
        }
        val response = generativeModel.generateContent(prompt)
        return response.text.orEmpty()
    }

    @OptIn(PublicPreviewAPI::class)
    suspend fun generateRecipeImage(recipe: String): Bitmap {
        val imageResponse = imagenModel.generateImages(recipe)
        return imageResponse.images.first().asBitmap()
    }
}