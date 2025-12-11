package com.google.firebase.example.friendlymeals.ui.recipe

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class RecipeViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle
) : MainViewModel() {
    private val recipeRoute = savedStateHandle.toRoute<RecipeRoute>()
    private val recipeId: String = recipeRoute.recipeId

    private val _recipe = MutableStateFlow(Recipe())
    val recipe: StateFlow<Recipe>
        get() = _recipe.asStateFlow()

    fun loadRecipe() {
        launchCatching {
            _recipe.value = Recipe(
                title = "Spaghetti Bolognese",
                instructions = "Boil some **pasta**, add some _tomato sauce_",
                ingredients = listOf("200g Pasta", "4 ripe tomatoes", "2 cloves garlic", "1/2 cup heavy cream", "Fresh basil leaves"),
                prepTime = "20 mins",
                cookTime = "30 mins",
                servings = "4",
                averageRating = 4.5,
                imageUrl = ""
            )
            //_recipe.value = repository.loadRecipe(recipeId)
            //TODO: load recipe from database
        }
    }

    fun toggleFavorite() {
        launchCatching {
            //_recipe.value = repository.addToFavorite(recipeId)
            //TODO: add recipe to favorites
        }
    }
}