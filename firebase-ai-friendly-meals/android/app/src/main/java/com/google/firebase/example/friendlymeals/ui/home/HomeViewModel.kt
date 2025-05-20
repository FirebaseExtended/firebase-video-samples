package com.google.firebase.example.friendlymeals.ui.home

import android.content.Context
import android.graphics.BitmapFactory
import androidx.core.content.FileProvider
import com.google.firebase.example.friendlymeals.BuildConfig
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.repository.AIRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.io.File
import javax.inject.Inject

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val aiRepository: AIRepository
) : MainViewModel() {
    private val _viewState = MutableStateFlow<HomeViewState>(HomeViewState())
    val viewState: StateFlow<HomeViewState>
        get() = _viewState.asStateFlow()

    fun onCameraPermissionGranted(context: Context) {
        launchCatching {
            val tempFile = File.createTempFile(
                "temp_image_file_",
                ".jpg",
                context.cacheDir
            )

            _viewState.value = _viewState.value.copy(
                tempFileUrl = FileProvider.getUriForFile(context,
                    "${BuildConfig.APPLICATION_ID}.provider",
                    tempFile
                )
            )
        }
    }

    fun onImageSaved(context: Context) {
        launchCatching {
            val tempImageUrl = _viewState.value.tempFileUrl
            if (tempImageUrl != null) {
                _viewState.value = _viewState.value.copy(
                    ingredientsLoading = true
                )

                val input = context.contentResolver.openInputStream(tempImageUrl)
                val bitmap = BitmapFactory.decodeStream(input)
                val ingredients = "apple, sugar"
                //TODO: call API to get ingredients from image

                _viewState.value = _viewState.value.copy(
                    tempFileUrl = null,
                    ingredientsLoading = false,
                    ingredients = ingredients,
                )
            }
        }
    }

    fun onImageCancelled() {
        _viewState.value = _viewState.value.copy(
            tempFileUrl = null,
            ingredientsLoading = false
        )
    }

    fun onIngredientsUpdated(ingredients: String) {
        _viewState.value = _viewState.value.copy(
            ingredients = ingredients
        )
    }

    fun generateRecipe(ingredients: String, notes: String) {
        launchCatching {
            _viewState.value = _viewState.value.copy(
                recipeLoading = true
            )

            val generatedRecipe = aiRepository.generateRecipe(ingredients, notes)
            val recipeImage = aiRepository.generateRecipeImage(generatedRecipe)

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