package com.google.firebase.example.friendlymeals.data.injection

import com.google.firebase.Firebase
import com.google.firebase.vertexai.GenerativeModel
import com.google.firebase.vertexai.ImagenModel
import com.google.firebase.vertexai.type.ImagenAspectRatio
import com.google.firebase.vertexai.type.ImagenImageFormat
import com.google.firebase.vertexai.type.ImagenPersonFilterLevel
import com.google.firebase.vertexai.type.ImagenSafetyFilterLevel
import com.google.firebase.vertexai.type.ImagenSafetySettings
import com.google.firebase.vertexai.type.PublicPreviewAPI
import com.google.firebase.vertexai.type.imagenGenerationConfig
import com.google.firebase.vertexai.vertexAI
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object FirebaseHiltModule {
    @Provides fun generativeModel(): GenerativeModel {
        return Firebase.vertexAI.generativeModel(
            modelName = "gemini-2.0-flash"
        )
    }

    @OptIn(PublicPreviewAPI::class)
    @Provides fun imagenModel(): ImagenModel {
        val generationConfig = imagenGenerationConfig {
            numberOfImages = 1
            aspectRatio = ImagenAspectRatio.PORTRAIT_3x4
            imageFormat = ImagenImageFormat.png()
        }

        val safetySettings = ImagenSafetySettings(
            safetyFilterLevel = ImagenSafetyFilterLevel.BLOCK_LOW_AND_ABOVE,
            personFilterLevel = ImagenPersonFilterLevel.BLOCK_ALL
        )
        return Firebase.vertexAI.imagenModel(
            modelName = "imagen-3.0-generate-002",
            generationConfig = generationConfig,
            safetySettings = safetySettings
        )
    }
}