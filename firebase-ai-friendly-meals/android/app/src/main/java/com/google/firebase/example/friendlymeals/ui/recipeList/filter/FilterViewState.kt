package com.google.firebase.example.friendlymeals.ui.recipeList.filter

data class FilterViewState(
    val recipeName: String = "",
    val username: String = "",
    val rating: Int = 1,
    val tags: List<String> = listOf("Quick & Easy", "Vegan", "Gluten-Free", "High Protein"),
    val sortBy: String = "Rating",
    //TODO: update this view state with data model from PRD
    //TODO: transform tags and sortBy options in ENUM
)