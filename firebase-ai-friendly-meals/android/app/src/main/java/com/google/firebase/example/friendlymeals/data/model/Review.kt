package com.google.firebase.example.friendlymeals.data.model

data class Review(
    val userId: String = "",
    val recipeId: String = "",
    val rating: Int = 0
)