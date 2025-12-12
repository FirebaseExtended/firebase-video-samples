package com.google.firebase.example.friendlymeals.ui.recipeList.filter

import com.google.firebase.example.friendlymeals.R

enum class SortByFilter(val title: Int) {
    RATING(R.string.filter_sort_by_rating),
    ALPHABETICAL(R.string.filter_sort_by_alphabetical),
    POPULARITY(R.string.filter_sort_by_popularity)
}