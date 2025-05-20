package com.google.firebase.example.friendlymeals.ui.home

import android.net.Uri
import com.google.firebase.example.friendlymeals.data.model.Recipe

data class HomeViewState(
    val tempFileUrl: Uri? = null,
    val ingredients: String = "",
    val recipe: Recipe? = null,
    val ingredientsLoading: Boolean = false,
    val recipeLoading: Boolean = false
)