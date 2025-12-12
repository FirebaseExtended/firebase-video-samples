package com.google.firebase.example.friendlymeals.ui.recipeList

import android.graphics.Bitmap

data class RecipeListItem(
    val id: String = "",
    val title: String = "",
    val averageRating: Double = 0.0,
    val image: Bitmap? = null
)