package com.google.firebase.example.friendlymeals.ui.auth

data class AuthViewState(
    val email: String = "",
    val password: String = "",
    val authLoading: Boolean = false
)