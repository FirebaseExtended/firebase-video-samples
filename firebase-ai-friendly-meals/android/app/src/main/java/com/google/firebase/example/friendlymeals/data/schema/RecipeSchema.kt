package com.google.firebase.example.friendlymeals.data.schema

import kotlinx.serialization.Serializable

@Serializable
data class RecipeSchema(
    val title: String = "",
    val instructions: String = "",
    val ingredients: List<String> = listOf(),
    val prepTime: String = "",
    val cookTime: String = "",
    val servings: String = ""
)