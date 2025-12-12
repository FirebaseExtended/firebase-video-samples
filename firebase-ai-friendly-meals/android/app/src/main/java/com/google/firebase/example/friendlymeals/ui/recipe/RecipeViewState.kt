package com.google.firebase.example.friendlymeals.ui.recipe

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.model.Recipe

data class RecipeViewState(
    val recipe: Recipe = Recipe(),
    val recipeImage: Bitmap? = null,
    val saved: Boolean = false,
    val rating: Int = 0
)