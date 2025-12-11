package com.google.firebase.example.friendlymeals.ui.scanMeal

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.model.MealBreakdown

data class ScanMealViewState(
    val mealBreakdown: MealBreakdown = MealBreakdown(),
    val image: Bitmap? = null,
    val scanLoading: Boolean = false
)