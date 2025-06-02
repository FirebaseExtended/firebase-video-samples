package com.google.firebase.example.friendlymeals.ui.home

import com.google.firebase.example.friendlymeals.data.model.Recipe

data class HomeViewState(
    val ingredients: String = "",
    val recipe: Recipe? = null,
    val ingredientsLoading: Boolean = false,
    val recipeLoading: Boolean = false
)