package com.google.firebase.example.friendlymeals.ui.auth

enum class AuthState {
    SIGN_IN, SIGN_UP, PROFILE
}

data class AuthViewState(
    val authState: AuthState = AuthState.SIGN_IN,
    val email: String = "",
    val password: String = "",
    val isLoading: Boolean = false //TODO: add loading view
)