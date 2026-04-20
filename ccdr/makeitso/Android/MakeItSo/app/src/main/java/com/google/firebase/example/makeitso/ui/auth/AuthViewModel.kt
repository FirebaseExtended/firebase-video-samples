package com.google.firebase.example.makeitso.ui.auth

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository,
    private val auth: FirebaseAuth
) : MainViewModel() {
    
    fun onSignInClick(email: String, password: String, onComplete: () -> Unit) {
        launchCatching {
            authRepository.signIn(email, password)
            onComplete()
        }
    }

    fun onSignUpClick(email: String, password: String, onComplete: () -> Unit) {
        launchCatching {
            authRepository.signUp(email, password)
            onComplete()
        }
    }

    fun onLinkAccountClick(email: String, password: String, onComplete: () -> Unit) {
        launchCatching {
            authRepository.linkAccount(email, password)
            onComplete()
        }
    }

    fun isAnonymous(): Boolean {
        return auth.currentUser?.isAnonymous == true
    }
}
