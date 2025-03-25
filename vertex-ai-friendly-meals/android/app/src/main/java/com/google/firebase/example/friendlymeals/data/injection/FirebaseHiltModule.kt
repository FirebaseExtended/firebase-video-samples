package com.google.firebase.example.friendlymeals.data.injection

import com.google.firebase.Firebase
import com.google.firebase.vertexai.GenerativeModel
import com.google.firebase.vertexai.ImagenModel
import com.google.firebase.vertexai.type.PublicPreviewAPI
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
        //TODO: Add Imagen 3 model configuration

        return Firebase.vertexAI.imagenModel(
            modelName = "imagen-3.0-generate-002"
        )
    }
}