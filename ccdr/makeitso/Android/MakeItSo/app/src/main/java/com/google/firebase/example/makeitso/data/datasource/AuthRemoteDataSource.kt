package com.google.firebase.example.makeitso.data.datasource

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import kotlin.text.orEmpty

class AuthRemoteDataSource @Inject constructor(
    private val auth: FirebaseAuth
) {
    val currentUser: FirebaseUser? get() = auth.currentUser

    suspend fun createAnonymousAccount(): String {
        val authResult = auth.signInAnonymously().await()
        return authResult.user?.uid.orEmpty()
    }
}