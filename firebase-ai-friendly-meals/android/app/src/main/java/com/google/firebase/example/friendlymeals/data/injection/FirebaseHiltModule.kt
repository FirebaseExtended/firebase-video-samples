package com.google.firebase.example.friendlymeals.data.injection

import com.google.firebase.Firebase
import com.google.firebase.ai.FirebaseAI
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.auth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.storage.StorageReference
import com.google.firebase.storage.storage
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
object FirebaseHiltModule {
    @Provides fun auth(): FirebaseAuth = Firebase.auth

    @Provides fun firebaseAI(): FirebaseAI {
        return Firebase.ai(backend = GenerativeBackend.googleAI())
    }

    @Provides fun storage(): StorageReference {
        return Firebase.storage.reference
    }

    @Provides fun firestore(): FirebaseFirestore {
        return FirebaseFirestore.getInstance("default")
    }
}