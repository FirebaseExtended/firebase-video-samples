package com.google.firebase.example.friendlymeals.ui.generate

import com.google.firebase.example.friendlymeals.data.model.Recipe

data class GenerateViewState(
    val ingredients: String = "",
    val recipe: Recipe? = null,
    val ingredientsLoading: Boolean = false,
    val recipeLoading: Boolean = false
)