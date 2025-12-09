package com.google.firebase.example.friendlymeals.data.repository

import com.google.firebase.example.friendlymeals.data.datasource.AuthRemoteDataSource
import javax.inject.Inject

class AuthRepository @Inject constructor(
    private val authRemoteDataSource: AuthRemoteDataSource
) {
    suspend fun createAnonymousAccount() {
        authRemoteDataSource.createAnonymousAccount()
    }
}