package com.google.firebase.example.friendlymeals.ui.home

import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
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
    private val _tempFileUrl = MutableStateFlow<Uri?>(null)
    val tempFileUrl: StateFlow<Uri?>
        get() = _tempFileUrl.asStateFlow()

    private val _recipe = MutableStateFlow<Recipe?>(null)
    val recipe: StateFlow<Recipe?>
        get() = _recipe.asStateFlow()

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean>
        get() = _loading.asStateFlow()

    fun onCameraPermissionGranted(context: Context) {
        val tempFile = File.createTempFile(
            "temp_image_file_",
            ".jpg",
            context.cacheDir
        )

        _tempFileUrl.value = FileProvider.getUriForFile(context,
            "${BuildConfig.APPLICATION_ID}.provider",
            tempFile
        )
    }

    fun onImageSaved(context: Context) {
        launchCatching {
            val tempImageUrl = _tempFileUrl.value
            if (tempImageUrl != null) {

                val input = context.contentResolver.openInputStream(tempImageUrl)
                val bitmap = BitmapFactory.decodeStream(input)

                //loading state on
                //call API
                //on API result clear temp file and loading state
                //add ingredients to the input
            }
        }
    }

    fun onImageCancelled() {
        _tempFileUrl.value = null
    }

    fun generateRecipe(ingredients: String, notes: String) {
        launchCatching {
            _loading.value = true
            val generatedRecipe = aiRepository.generateRecipe(ingredients, notes)
            val recipeImage = aiRepository.generateRecipeImage(generatedRecipe)

            _loading.value = false
            _recipe.value = Recipe(
                description = generatedRecipe,
                image = recipeImage
            )
        }
    }
}