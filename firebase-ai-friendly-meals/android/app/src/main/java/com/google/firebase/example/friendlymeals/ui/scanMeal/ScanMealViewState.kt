package com.google.firebase.example.friendlymeals.ui.scanMeal

import android.graphics.Bitmap

data class ScanMealViewState(
    val protein: String = "0g",
    val fat: String = "0g",
    val carbs: String = "0g",
    val sugar: String = "0g",
    val ingredients: List<String> = emptyList(),
    val image: Bitmap? = null,
    val scanLoading: Boolean = false
)