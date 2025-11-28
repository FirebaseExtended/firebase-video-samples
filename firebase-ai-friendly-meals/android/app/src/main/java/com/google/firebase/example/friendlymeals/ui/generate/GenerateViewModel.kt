package com.google.firebase.example.friendlymeals.ui.generate

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.repository.AIRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class GenerateViewModel @Inject constructor(
    private val aiRepository: AIRepository
) : MainViewModel() {
    private val _viewState = MutableStateFlow(GenerateViewState())
    val viewState: StateFlow<GenerateViewState>
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

    fun generateRecipe(ingredients: String, notes: String, openRecipeScreen: (String) -> Unit) {
        launchCatching {
            _viewState.value = _viewState.value.copy(
                recipeLoading = true
            )

            val generatedRecipe = aiRepository.generateRecipe(ingredients, notes)
            val recipeImage = aiRepository.generateRecipePhoto(generatedRecipe)
            //TODO: save recipe to database and recipe image to storage
            //TODO: need to create storageDataSource and repository
            //TODO: need to create firestoreDataSource and repository

            _viewState.value = _viewState.value.copy(
                recipeLoading = false
            )

            openRecipeScreen("") //TODO: Add Recipe id returned by Firestore
        }
    }
}