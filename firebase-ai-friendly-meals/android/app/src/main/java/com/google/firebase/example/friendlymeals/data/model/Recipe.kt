package com.google.firebase.example.friendlymeals.data.model

import android.graphics.Bitmap

data class Recipe(
    val title: String = "",
    val instructions: String = "",
    val ingredients: List<String> = listOf(),
    val prepTime: String = "",
    val cookTime: String = "",
    val servings: String = "",
    val averageRating: Double = 0.0,
    val image: Bitmap? = null
)