package com.google.firebase.example.friendlymeals.ui.recipeList

import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.data.repository.DatabaseRepository
import com.google.firebase.example.friendlymeals.data.repository.StorageRepository
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterOptions
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
    private val _filterOptions = MutableStateFlow(FilterOptions())
    val filterOptions: StateFlow<FilterOptions>
        get() = _filterOptions.asStateFlow()

    private val _tags = MutableStateFlow(listOf<Tag>())
    val tags: StateFlow<List<Tag>>
        get() = _tags.asStateFlow()

    private val _recipes = MutableStateFlow<List<RecipeListItem>>(listOf())
    val recipes: StateFlow<List<RecipeListItem>>
        get() = _recipes.asStateFlow()

    fun loadRecipes() {
        launchCatching {
            val recipeListItems = mutableListOf<RecipeListItem>()

            databaseRepository.getAllRecipes().forEach {
                recipeListItems.add(it.toRecipeListItem())
            }

            _recipes.value = recipeListItems

            loadImages()
        }
    }

    suspend fun loadImages() {
        val recipeWithImages = mutableListOf<RecipeListItem>()

        _recipes.value.forEach {
            val imageUri = storageRepository.getImageUri(it.id)
            recipeWithImages.add(it.copy(imageUri = imageUri))
        }

        _recipes.value = recipeWithImages
    }

    fun loadPopularTags() {
        launchCatching {
            _tags.value = databaseRepository.getPopularTags()
        }
    }

    fun updateRecipeTitle(recipeName: String) {
        _filterOptions.value = _filterOptions.value.copy(recipeTitle = recipeName)
    }

    fun updateIngredients(ingredients: String) {
        _filterOptions.value = _filterOptions.value.copy(ingredients = ingredients)
    }

    fun updateFilterByMine() {
        val currentValue = _filterOptions.value.filterByMine
        _filterOptions.value = _filterOptions.value.copy(filterByMine = !currentValue)
    }

    fun updateRating(rating: Int) {
        _filterOptions.value = _filterOptions.value.copy(rating = rating)
    }

    fun removeTag(tag: String) {
        _filterOptions.value = _filterOptions.value.copy(
            selectedTags = _filterOptions.value.selectedTags.filter { it != tag }
        )
    }

    fun addTag(tag: String) {
        _filterOptions.value = _filterOptions.value.copy(
            selectedTags = _filterOptions.value.selectedTags + tag
        )
    }

    fun updateSortBy(sortByFilter: SortByFilter) {
        _filterOptions.value = _filterOptions.value.copy(sortBy = sortByFilter)
    }

    fun resetFilters() {
        _filterOptions.value = FilterOptions()
        loadRecipes()
    }

    fun applyFilters() {
        launchCatching {
            val filteredItems = mutableListOf<RecipeListItem>()

            databaseRepository.getFilteredRecipes(_filterOptions.value).forEach {
                filteredItems.add(it.toRecipeListItem())
            }

            _recipes.value = filteredItems

            loadImages()
        }
    }

    private fun Recipe.toRecipeListItem(): RecipeListItem {
        return RecipeListItem(
            id = id,
            title = title,
            averageRating = averageRating
        )
    }
}