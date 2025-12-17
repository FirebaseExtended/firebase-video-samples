package com.google.firebase.example.friendlymeals.ui.recipeList.filter

import com.google.firebase.example.friendlymeals.ui.recipeList.filter.SortByFilter.RATING

data class FilterOptions(
    val recipeTitle: String = "",
    val ingredients: String = "",
    val filterByMine: Boolean = false,
    val rating: Int = 0,
    val selectedTags: List<String> = listOf(),
    val sortBy: SortByFilter = RATING
)