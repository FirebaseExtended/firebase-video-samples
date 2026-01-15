package com.google.firebase.example.friendlymeals.ui.scanMeal

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.schema.MealSchema

data class ScanMealViewState(
    val mealSchema: MealSchema = MealSchema(),
    val image: Bitmap? = null,
    val scanLoading: Boolean = false
)