package com.google.firebase.example.makeitso.data.datasource

import com.google.firebase.auth.EmailAuthProvider
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

    suspend fun signUp(email: String, password: String) {
        auth.createUserWithEmailAndPassword(email, password).await()
    }

    suspend fun signIn(email: String, password: String) {
        auth.signInWithEmailAndPassword(email, password).await()
    }

    suspend fun linkAccount(email: String, password: String) {
        val credential = EmailAuthProvider.getCredential(email, password)
        auth.currentUser?.linkWithCredential(credential)?.await()
    }

    fun signOut() {
        auth.signOut()
    }
}