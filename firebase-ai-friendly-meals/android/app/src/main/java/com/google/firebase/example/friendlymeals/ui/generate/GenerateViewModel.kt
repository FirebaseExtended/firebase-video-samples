package com.google.firebase.example.friendlymeals.ui.generate

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.repository.AIRepository
import com.google.firebase.example.friendlymeals.data.repository.AuthRepository
import com.google.firebase.example.friendlymeals.data.repository.StorageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class GenerateViewModel @Inject constructor(
    private val aiRepository: AIRepository,
    private val authRepository: AuthRepository,
    private val storageRepository: StorageRepository
) : MainViewModel() {
    private val _viewState = MutableStateFlow(GenerateViewState())
    val viewState: StateFlow<GenerateViewState>
        get() = _viewState.asStateFlow()

    fun loadCurrentUser() {
        launchCatching {
            if (authRepository.currentUser == null) {
                authRepository.createAnonymousAccount()
                //TODO: store user in Firestore
            }
        }
    }

    fun onIngredientsUpdated(ingredients: String) {
        _viewState.value = _viewState.value.copy(
            ingredients = ingredients
        )
    }

    fun onNotesUpdated(notes: String) {
        _viewState.value = _viewState.value.copy(
            notes = notes
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

    fun generateRecipe(openRecipeScreen: (String) -> Unit) {
        launchCatching {
            _viewState.value = _viewState.value.copy(
                recipeLoading = true
            )

            val generatedRecipe = aiRepository.generateRecipe(
                _viewState.value.ingredients,
                _viewState.value.notes
            )

            val recipeImage = aiRepository.generateRecipePhoto(generatedRecipe.title)

            if (recipeImage != null) {
                storageRepository.storeImage(recipeImage, "1")
                //TODO: replace this id by the real id returned by Firestore
            }

            //TODO: save recipe to Firestore
            //TODO: save tags to Firestore

            _viewState.value = _viewState.value.copy(
                recipeLoading = false
            )

            openRecipeScreen("") //TODO: Add Recipe id returned by Firestore
        }
    }
}