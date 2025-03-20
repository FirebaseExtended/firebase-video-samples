package com.google.firebase.example.friendlymeals.data.model

import android.graphics.Bitmap

data class Recipe(
    val title: String = "",
    val description: String = "",
    val ingredients: List<String> = listOf(),
    val steps: List<String> = listOf(),
    val image: Bitmap? = null
)