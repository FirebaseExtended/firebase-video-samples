package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import com.google.firebase.vertexai.GenerativeModel
import com.google.firebase.vertexai.ImagenModel
import com.google.firebase.vertexai.type.PublicPreviewAPI
import com.google.firebase.vertexai.type.content
import javax.inject.Inject

@OptIn(PublicPreviewAPI::class)
class AIRemoteDataSource @Inject constructor(
    private val generativeModel: GenerativeModel,
    private val imagenModel: ImagenModel,
) {
    suspend fun generateIngredients(image: Bitmap): String {
        val prompt = content {
            image(image)
            text("Please analyze this image and list all visible food ingredients. " +
                    "Format the response as a comma-separated list of ingredients. " +
                    "Be specific with measurements where possible, " +
                    "but focus on identifying the ingredients accurately.")
        }

        val response = generativeModel.generateContent(prompt)
        return response.text.orEmpty()
    }

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
        val prompt = "A professional food photography shot of this recipe: $recipe. " +
                "Style: High-end food photography, restaurant-quality plating, soft natural " +
                "lighting, on a clean background, showing the complete plated dish."
        val imageResponse = imagenModel.generateImages(prompt)
        return imageResponse.images.first().asBitmap()
    }
}