package com.google.firebase.example.friendlymeals.data.model

data class Save(
    val recipeId: String = "",
    val userId: String = "",
    val isFavorite: Boolean = false
)