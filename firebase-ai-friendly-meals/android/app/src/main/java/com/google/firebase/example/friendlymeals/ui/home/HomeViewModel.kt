package com.google.firebase.example.friendlymeals.ui.home

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.repository.AIRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val aiRepository: AIRepository
) : MainViewModel() {
    private val _viewState = MutableStateFlow<HomeViewState>(HomeViewState())
    val viewState: StateFlow<HomeViewState>
        get() = _viewState.asStateFlow()

    fun onIngredientsUpdated(ingredients: String) {
        _viewState.value = _viewState.value.copy(
            ingredients = ingredients
        )
    }

    fun onImageTaken(image: Bitmap?) {
        launchCatching {
            if (image != null) {
                _viewState.value = _viewState.value.copy(
                    ingredientsLoading = true
                )

                val ingredients = aiRepository.generateIngredients(image)

                _viewState.value = _viewState.value.copy(
                    ingredientsLoading = false,
                    ingredients = ingredients
                )
            }
        }
    }

    fun generateRecipe(ingredients: String, notes: String) {
        launchCatching {
            _viewState.value = _viewState.value.copy(
                recipeLoading = true
            )

            val generatedRecipe = aiRepository.generateRecipe(ingredients, notes)
            val recipeImage = aiRepository.generateRecipePhoto(generatedRecipe)

            _viewState.value = _viewState.value.copy(
                recipeLoading = false,
                recipe = Recipe(
                    description = generatedRecipe,
                    image = recipeImage
                )
            )
        }
    }
}