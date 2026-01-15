package com.google.firebase.example.friendlymeals.data.datasource

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.example.friendlymeals.data.model.User
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

class AuthRemoteDataSource @Inject constructor(private val auth: FirebaseAuth) {
    val currentUser: FirebaseUser? get() = auth.currentUser

    suspend fun createAnonymousAccount(): User {
        val authResult = auth.signInAnonymously().await()
        return User(authResult.user?.uid.orEmpty())
    }
}