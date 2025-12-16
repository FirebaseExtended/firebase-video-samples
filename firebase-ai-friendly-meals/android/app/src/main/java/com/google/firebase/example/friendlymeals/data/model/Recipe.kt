package com.google.firebase.example.friendlymeals.data.model

data class Recipe(
    val id: String = "",
    val title: String = "",
    val instructions: String = "",
    val ingredients: List<String> = listOf(),
    val authorId: String = "",
    val tags: List<String> = listOf(),
    val averageRating: Double = 0.0,
    val prepTime: String = "",
    val cookTime: String = "",
    val servings: String = ""
)