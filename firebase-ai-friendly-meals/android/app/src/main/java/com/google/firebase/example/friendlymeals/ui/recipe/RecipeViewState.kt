package com.google.firebase.example.friendlymeals.ui.recipe

import com.google.firebase.example.friendlymeals.data.model.Recipe

data class RecipeViewState(
    val recipe: Recipe = Recipe(),
    val imageUri: String? = null,
    val favorite: Boolean = false,
    val rating: Int = 0
)