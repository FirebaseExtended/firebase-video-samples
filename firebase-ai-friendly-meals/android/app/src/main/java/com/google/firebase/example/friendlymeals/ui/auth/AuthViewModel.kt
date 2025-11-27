package com.google.firebase.example.friendlymeals.ui.auth

import com.google.firebase.example.friendlymeals.MainViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor() : MainViewModel() {
    private val _viewState = MutableStateFlow(AuthViewState())
    val viewState: StateFlow<AuthViewState>
        get() = _viewState.asStateFlow()

    fun updateEmail(email: String) {
        _viewState.value = _viewState.value.copy(email = email)
    }

    fun updatePassword(password: String) {
        _viewState.value = _viewState.value.copy(password = password)
    }

    fun signInWithEmail() {
        launchCatching {
            //TODO: sign in user with email, add loading state
        }
    }

    fun signUpWithEmail() {
        launchCatching {
            //TODO: sign up user with email, add loading state
        }
    }

    fun signInWithGoogle() {
        launchCatching {
            //TODO: sign in user with Google, add loading state
        }
    }

    fun signUpWithGoogle() {
        launchCatching {
            //TODO: sign up user with Google, add loading state
        }
    }

    fun forgotPassword() {
        launchCatching {
            //TODO: send password reset email, display snackbar
        }
    }
}