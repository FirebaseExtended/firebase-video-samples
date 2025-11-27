package com.google.firebase.example.friendlymeals.ui.generate

data class GenerateViewState(
    val ingredients: String = "",
    val ingredientsLoading: Boolean = false,
    val recipeLoading: Boolean = false
)