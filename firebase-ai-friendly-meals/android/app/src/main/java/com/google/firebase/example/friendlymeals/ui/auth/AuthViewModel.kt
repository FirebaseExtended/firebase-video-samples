package com.google.firebase.example.friendlymeals.ui.auth

import androidx.credentials.Credential
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : MainViewModel() {
    private val _viewState = MutableStateFlow(AuthViewState())
    val viewState: StateFlow<AuthViewState>
        get() = _viewState.asStateFlow()

    fun loadUser() {
        //TODO: load current user and navigate to generate screen if already authenticated
        //TODO: need to create authDataSource and repository
    }

    fun updateAuthState(authState: AuthState) {
        _viewState.value = _viewState.value.copy(authState = authState)
    }

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

    fun signInWithGoogle(credential: Credential) {
        launchCatching {
            //TODO: sign in user with Google, add loading state
            //TODO: add credential manager library and code
        }
    }

    fun signUpWithGoogle(credential: Credential) {
        launchCatching {
            //TODO: sign up user with Google, add loading state
        }
    }
}