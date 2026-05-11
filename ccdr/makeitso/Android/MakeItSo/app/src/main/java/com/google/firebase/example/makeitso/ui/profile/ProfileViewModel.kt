package com.google.firebase.example.makeitso.ui.profile

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val authRepository: AuthRepository,
    private val auth: FirebaseAuth
) : MainViewModel() {
    val currentUser = callbackFlow {
        val listener = FirebaseAuth.IdTokenListener { 
            trySend(it.currentUser)
        }
        auth.addIdTokenListener(listener)
        trySend(auth.currentUser)
        awaitClose { auth.removeIdTokenListener(listener) }
    }

    fun onSignOut(onComplete: () -> Unit) {
        launchCatching {
            authRepository.signOut()
            authRepository.createAnonymousAccount()
            onComplete()
        }
    }
}
