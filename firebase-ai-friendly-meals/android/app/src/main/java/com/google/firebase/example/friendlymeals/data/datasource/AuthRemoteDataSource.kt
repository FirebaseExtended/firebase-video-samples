package com.google.firebase.example.friendlymeals.data.datasource

import com.google.firebase.Firebase
import com.google.firebase.auth.EmailAuthProvider
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.auth.auth
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

class AuthRemoteDataSource @Inject constructor() {
    suspend fun createAnonymousAccount() {
        Firebase.auth.signInAnonymously().await()
    }
}