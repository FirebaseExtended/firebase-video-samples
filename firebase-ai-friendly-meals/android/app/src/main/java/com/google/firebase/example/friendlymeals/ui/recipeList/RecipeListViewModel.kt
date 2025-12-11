package com.google.firebase.example.friendlymeals.ui.recipeList

import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterViewState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class RecipeListViewModel @Inject constructor() : MainViewModel() {
    private val _filterState = MutableStateFlow(FilterViewState())
    val filterState: StateFlow<FilterViewState>
        get() = _filterState.asStateFlow()

    private val _recipes = MutableStateFlow<List<Recipe>>(listOf())
    val recipes: StateFlow<List<Recipe>>
        get() = _recipes.asStateFlow()

    fun loadRecipes() {
        launchCatching {
            _recipes.value = listOf(Recipe(
                title = "Spaghetti Bolognese",
                instructions = "Boil some **pasta**, add some _tomato sauce_",
                ingredients = listOf("200g Pasta", "4 ripe tomatoes", "2 cloves garlic", "1/2 cup heavy cream", "Fresh basil leaves"),
                prepTime = "20 mins",
                cookTime = "30 mins",
                servings = "4",
                averageRating = 3.0
            ))
            //_recipes.value = repository.loadRecipes()
            //TODO: load recipes from database
        }
    }

    fun updateRecipeName(recipeName: String) {
        _filterState.value = _filterState.value.copy(recipeName = recipeName)
    }

    fun updateUsername(username: String) {
        _filterState.value = _filterState.value.copy(username = username)
    }

    fun updateRating(rating: Int) {
        _filterState.value = _filterState.value.copy(rating = rating)
    }

    fun removeTag(tag: String) {
        _filterState.value = _filterState.value.copy(
            tags = _filterState.value.tags.filter { it != tag }
        )
    }

    fun addTag(tag: String) {
        _filterState.value = _filterState.value.copy(
            tags = _filterState.value.tags + tag
        )
    }

    fun updateSortBy(sortBy: String) {
        _filterState.value = _filterState.value.copy(sortBy = sortBy)
    }

    fun resetFilters() {
        _filterState.value = FilterViewState()
    }

    fun applyFilters() {
        //TODO: Firestore call with filters, update recipe list
    }
}