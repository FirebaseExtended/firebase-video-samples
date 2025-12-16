package com.google.firebase.example.friendlymeals.ui.recipeList

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.data.repository.DatabaseRepository
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
    private val storageRepository: StorageRepository,
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {
    private val _filterState = MutableStateFlow(FilterViewState())
    val filterState: StateFlow<FilterViewState>
        get() = _filterState.asStateFlow()

    private val _tags = MutableStateFlow(listOf<Tag>())
    val tags: StateFlow<List<Tag>>
        get() = _tags.asStateFlow()

    private val _recipes = MutableStateFlow<List<RecipeListItem>>(listOf())
    val recipes: StateFlow<List<RecipeListItem>>
        get() = _recipes.asStateFlow()

    fun loadRecipes() {
        launchCatching {
            val allRecipes = databaseRepository.getAllRecipes()
            val recipeListItems = mutableListOf<RecipeListItem>()

            allRecipes.forEach {
                val image = storageRepository.getImage(it.id)
                recipeListItems.add(it.toRecipeListItem(image))
            }
            _recipes.value = recipeListItems
        }
    }

    fun loadPopularTags() {
        launchCatching {
            _tags.value = databaseRepository.getPopularTags()
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
        //TODO: Firestore call with filters, update recipe list, add 'isFiltering' to control it
    }

    private fun Recipe.toRecipeListItem(image: Bitmap?): RecipeListItem {
        return RecipeListItem(
            id = id,
            title = title,
            averageRating = averageRating,
            image = image
        )
    }
}