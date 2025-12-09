package com.google.firebase.example.friendlymeals.data.repository

import com.google.firebase.auth.FirebaseUser
import com.google.firebase.example.friendlymeals.data.datasource.AuthRemoteDataSource
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class AuthRepository @Inject constructor(
    private val authRemoteDataSource: AuthRemoteDataSource
) {
    val currentUser: FirebaseUser? = authRemoteDataSource.currentUser
    val currentUserIdFlow: Flow<String?> = authRemoteDataSource.currentUserIdFlow

    suspend fun createAnonymousAccount() {
        authRemoteDataSource.createAnonymousAccount()
    }
}