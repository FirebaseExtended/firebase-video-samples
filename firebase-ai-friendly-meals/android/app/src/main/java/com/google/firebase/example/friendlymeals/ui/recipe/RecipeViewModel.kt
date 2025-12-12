package com.google.firebase.example.friendlymeals.ui.recipe

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.repository.StorageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class RecipeViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val storageRepository: StorageRepository
) : MainViewModel() {
    private val recipeRoute = savedStateHandle.toRoute<RecipeRoute>()
    private val recipeId: String = recipeRoute.recipeId

    private val _recipeViewState = MutableStateFlow(RecipeViewState())
    val recipeViewState: StateFlow<RecipeViewState>
        get() = _recipeViewState.asStateFlow()

    fun loadRecipe() {
        launchCatching {
            //TODO: load image from Storage
                //storageRepository.retrieveImage(recipeId)

            //TODO: load recipe from Firestore

            _recipeViewState.value = RecipeViewState(
                recipe = Recipe(
                    title = "Spaghetti Bolognese",
                    instructions = "Boil some **pasta**, add some _tomato sauce_",
                    ingredients = listOf("200g Pasta", "4 ripe tomatoes", "2 cloves garlic", "1/2 cup heavy cream", "Fresh basil leaves"),
                    prepTime = "20 mins",
                    cookTime = "30 mins",
                    servings = "4",
                    averageRating = 4.5,
                )
            )
        }
    }

    fun toggleFavorite() {
        launchCatching {
            val currentValue = _recipeViewState.value.saved
            _recipeViewState.value = _recipeViewState.value.copy(saved = !currentValue)
            //TODO: add recipe to favorites on Firestore
        }
    }

    fun leaveReview(rating: Int) {
        launchCatching {
            _recipeViewState.value = _recipeViewState.value.copy(rating = rating)
            //TODO: add review to Firestore
        }
    }
}