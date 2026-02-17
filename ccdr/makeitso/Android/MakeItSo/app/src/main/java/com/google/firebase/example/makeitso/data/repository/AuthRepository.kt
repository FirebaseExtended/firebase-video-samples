package com.google.firebase.example.makeitso.data.repository

import com.google.firebase.auth.FirebaseUser
import com.google.firebase.example.makeitso.data.datasource.AuthRemoteDataSource
import javax.inject.Inject

class AuthRepository @Inject constructor(
    private val authRemoteDataSource: AuthRemoteDataSource
) {
    val currentUser: FirebaseUser? = authRemoteDataSource.currentUser

    suspend fun createAnonymousAccount(): String {
        return authRemoteDataSource.createAnonymousAccount()
    }
}