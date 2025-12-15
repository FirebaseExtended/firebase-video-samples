package com.google.firebase.example.friendlymeals.ui.recipeList

import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.repository.StorageRepository
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterViewState
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.SortByFilter
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class RecipeListViewModel @Inject constructor(
    private val storageRepository: StorageRepository
) : MainViewModel() {
    private val _filterState = MutableStateFlow(FilterViewState())
    val filterState: StateFlow<FilterViewState>
        get() = _filterState.asStateFlow()

    private val _tags = MutableStateFlow(DEFAULT_TAGS)
    val tags: StateFlow<List<String>>
        get() = _tags.asStateFlow()

    private val _recipes = MutableStateFlow<List<RecipeListItem>>(listOf())
    val recipes: StateFlow<List<RecipeListItem>>
        get() = _recipes.asStateFlow()

    fun loadRecipes() {
        launchCatching {
            _recipes.value = listOf(RecipeListItem(
                title = "Spaghetti Bolognese"
            ))
            //TODO: load recipes from Firestore
            //TODO: for each downloaded recipe, load image:
                //_recipeImage.value = storageRepository.retrieveImage(recipeId)

            //TODO: fetch tags from Firestore
                //if tags is empty, load from companion object
        }
    }

    fun updateRecipeTitle(recipeName: String) {
        _filterState.value = _filterState.value.copy(recipeTitle = recipeName)
    }

    fun updateIngredients(ingredients: String) {
        _filterState.value = _filterState.value.copy(ingredients = ingredients)
    }

    fun updateFilterByMine() {
        val currentValue = _filterState.value.filterByMine
        _filterState.value = _filterState.value.copy(filterByMine = !currentValue)
    }

    fun updateRating(rating: Int) {
        _filterState.value = _filterState.value.copy(rating = rating)
    }

    fun removeTag(tag: String) {
        _filterState.value = _filterState.value.copy(
            selectedTags = _filterState.value.selectedTags.filter { it != tag }
        )
    }

    fun addTag(tag: String) {
        _filterState.value = _filterState.value.copy(
            selectedTags = _filterState.value.selectedTags + tag
        )
    }

    fun updateSortBy(sortByFilter: SortByFilter) {
        _filterState.value = _filterState.value.copy(sortBy = sortByFilter)
    }

    fun resetFilters() {
        _filterState.value = FilterViewState()
    }

    fun applyFilters() {
        //TODO: Firestore call with filters, update recipe list
    }

    companion object {
        private val DEFAULT_TAGS = listOf(
            "Quick & Easy",
            "Vegan",
            "Gluten-Free",
            "High Protein",
            "Dessert"
        )
    }
}