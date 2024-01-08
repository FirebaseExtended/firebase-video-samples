package com.notes.app.model.service

import com.notes.app.model.User
import kotlinx.coroutines.flow.Flow

interface AccountService {
    val currentUser: Flow<User?>
    val currentUserId: String
    fun hasUser(): Boolean
    suspend fun createAnonymousAccount()
    suspend fun linkAccount(email: String, password: String)
    suspend fun signIn(email: String, password: String)
    suspend fun signOut()
    suspend fun deleteAccount()
}
