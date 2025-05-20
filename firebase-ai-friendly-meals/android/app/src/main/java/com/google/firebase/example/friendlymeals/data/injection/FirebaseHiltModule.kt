package com.google.firebase.example.friendlymeals.data.injection

import com.google.firebase.Firebase
import com.google.firebase.ai.GenerativeModel
import com.google.firebase.ai.ImagenModel
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.ImagenAspectRatio
import com.google.firebase.ai.type.ImagenImageFormat
import com.google.firebase.ai.type.ImagenPersonFilterLevel
import com.google.firebase.ai.type.ImagenSafetyFilterLevel
import com.google.firebase.ai.type.ImagenSafetySettings
import com.google.firebase.ai.type.PublicPreviewAPI
import com.google.firebase.ai.type.imagenGenerationConfig
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object FirebaseHiltModule {
    @Provides fun generativeModel(): GenerativeModel {
        return Firebase.ai(backend = GenerativeBackend.googleAI())
            .generativeModel("gemini-2.0-flash")
    }

    @OptIn(PublicPreviewAPI::class)
    @Provides fun imagenModel(): ImagenModel {
        val generationConfig = imagenGenerationConfig {
            numberOfImages = 1
            aspectRatio = ImagenAspectRatio.SQUARE_1x1
            imageFormat = ImagenImageFormat.png()
        }

        val safetySettings = ImagenSafetySettings(
            safetyFilterLevel = ImagenSafetyFilterLevel.BLOCK_LOW_AND_ABOVE,
            personFilterLevel = ImagenPersonFilterLevel.BLOCK_ALL
        )

        return Firebase.ai.imagenModel(
            modelName = "imagen-3.0-generate-002",
            generationConfig = generationConfig,
            safetySettings = safetySettings
        )
    }
}