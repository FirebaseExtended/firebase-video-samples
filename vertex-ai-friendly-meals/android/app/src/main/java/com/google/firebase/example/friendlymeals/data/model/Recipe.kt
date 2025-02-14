package com.google.firebase.example.friendlymeals.data.model

data class Recipe(
    val id: String = "",
    val title: String = "",
    val description: String = "",
    val ingredients: List<String> = listOf(),
    val steps: List<String> = listOf()
)