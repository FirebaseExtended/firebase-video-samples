package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import com.google.firebase.ai.FirebaseAI
import com.google.firebase.ai.GenerativeModel
import com.google.firebase.ai.ImagenModel
import com.google.firebase.ai.type.ImagePart
import com.google.firebase.ai.type.ImagenAspectRatio
import com.google.firebase.ai.type.ImagenImageFormat
import com.google.firebase.ai.type.ImagenPersonFilterLevel
import com.google.firebase.ai.type.ImagenSafetyFilterLevel
import com.google.firebase.ai.type.ImagenSafetySettings
import com.google.firebase.ai.type.ResponseModality
import com.google.firebase.ai.type.content
import com.google.firebase.ai.type.generationConfig
import com.google.firebase.ai.type.imagenGenerationConfig
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import javax.inject.Inject

class AIRemoteDataSource @Inject constructor(
    private val firebaseAI: FirebaseAI,
    private val remoteConfig: FirebaseRemoteConfig
) {
    val generativeModel: GenerativeModel get() =
        firebaseAI.generativeModel(
            modelName = remoteConfig.getString("model_name"),
            generationConfig = generationConfig {
                responseModalities = listOf(ResponseModality.TEXT, ResponseModality.IMAGE)
            }
        )

    val imagenModel: ImagenModel get() =
        firebaseAI.imagenModel(
            modelName = remoteConfig.getString("imagen_name"),
            generationConfig = imagenGenerationConfig {
                numberOfImages = 1
                aspectRatio = ImagenAspectRatio.SQUARE_1x1
                imageFormat = ImagenImageFormat.png()
            },
            safetySettings = ImagenSafetySettings(
                safetyFilterLevel = ImagenSafetyFilterLevel.BLOCK_LOW_AND_ABOVE,
                personFilterLevel = ImagenPersonFilterLevel.BLOCK_ALL
            )
        )

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

    suspend fun generateRecipePhoto(recipe: String): Bitmap? {
        val prompt = "A professional food photography shot of this recipe: $recipe. " +
                "Style: High-end food photography, restaurant-quality plating, soft natural " +
                "lighting, on a clean background, showing the complete plated dish."

        return generativeModel.generateContent(prompt)
            .candidates.firstOrNull()?.content?.parts
            ?.filterIsInstance<ImagePart>()?.firstOrNull()?.image
    }

    suspend fun generateRecipePhotoImagen(recipe: String): Bitmap {
        val prompt = "A professional food photography shot of this recipe: $recipe. " +
                "Style: High-end food photography, restaurant-quality plating, soft natural " +
                "lighting, on a clean background, showing the complete plated dish."

        val imageResponse = imagenModel.generateImages(prompt)
        return imageResponse.images.first().asBitmap()
    }
}