package com.google.firebase.example.friendlymeals.data.model

import kotlinx.serialization.Serializable

@Serializable
data class MealBreakdown(
    val protein: String = "0g",
    val fat: String = "0g",
    val carbs: String = "0g",
    val sugar: String = "0g",
    val ingredients: List<String> = emptyList()
)