package com.google.firebase.example.friendlymeals.data.repository

import com.google.firebase.auth.FirebaseUser
import com.google.firebase.example.friendlymeals.data.datasource.AuthRemoteDataSource
import com.google.firebase.example.friendlymeals.data.model.User
import javax.inject.Inject

class AuthRepository @Inject constructor(
    private val authRemoteDataSource: AuthRemoteDataSource
) {
    val currentUser: FirebaseUser? = authRemoteDataSource.currentUser

    suspend fun createAnonymousAccount(): User {
        return authRemoteDataSource.createAnonymousAccount()
    }
}