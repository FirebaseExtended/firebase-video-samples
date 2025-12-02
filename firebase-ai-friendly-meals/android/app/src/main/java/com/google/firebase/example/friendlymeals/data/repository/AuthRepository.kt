package com.google.firebase.example.friendlymeals.data.repository

import com.google.firebase.example.friendlymeals.data.datasource.AuthRemoteDataSource
import javax.inject.Inject

class AuthRepository @Inject constructor(
    private val authRemoteDataSource: AuthRemoteDataSource
) {
    suspend fun createAnonymousAccount() {
        authRemoteDataSource.createAnonymousAccount()
    }

    suspend fun linkAccountWithGoogle(idToken: String) {
        authRemoteDataSource.linkAccountWithGoogle(idToken)
    }

    suspend fun linkAccountWithEmail(email: String, password: String) {
        authRemoteDataSource.linkAccountWithEmail(email, password)
    }

    suspend fun signInWithGoogle(idToken: String) {
        authRemoteDataSource.signInWithGoogle(idToken)
    }

    suspend fun signInWithEmail(email: String, password: String) {
        authRemoteDataSource.signInWithEmail(email, password)
    }

    suspend fun signOut() {
        authRemoteDataSource.signOut()
    }
}