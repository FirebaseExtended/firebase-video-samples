package com.google.firebase.example.friendlymeals.ui.generate

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.repository.AIRepository
import com.google.firebase.example.friendlymeals.data.repository.AuthRepository
import com.google.firebase.example.friendlymeals.data.repository.DatabaseRepository
import com.google.firebase.example.friendlymeals.data.repository.StorageRepository
import com.google.firebase.example.friendlymeals.data.schema.RecipeSchema
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class GenerateViewModel @Inject constructor(
    private val aiRepository: AIRepository,
    private val authRepository: AuthRepository,
    private val storageRepository: StorageRepository,
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {
    private val _viewState = MutableStateFlow(GenerateViewState())
    val viewState: StateFlow<GenerateViewState>
        get() = _viewState.asStateFlow()

    init {
        loadCurrentUser()
    }

    fun loadCurrentUser() {
        launchCatching {
            if (authRepository.currentUser == null) {
                val user = authRepository.createAnonymousAccount()
                databaseRepository.addUser(user)
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

    fun onImageTaken(image: Bitmap?, showError: () -> Unit) {
        if (image == null) {
            showError()
            return
        }

        launchCatching {
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

    fun generateRecipe(
        openRecipeScreen: (String) -> Unit,
        showError: () -> Unit
    ) {
        launchCatching {
            _viewState.value = _viewState.value.copy(
                recipeLoading = true
            )

            val generatedRecipe = aiRepository.generateRecipe(
                _viewState.value.ingredients,
                _viewState.value.notes
            )

            if (generatedRecipe == null) {
                _viewState.value = _viewState.value.copy(
                    recipeLoading = false
                )

                showError()
                return@launchCatching
            }

            val recipeImage = aiRepository.generateRecipePhoto(generatedRecipe.title)
            var recipeImageUri: String? = null

            if (recipeImage != null) {
                recipeImageUri = storageRepository.addImage(recipeImage)
            }

            databaseRepository.addTags(generatedRecipe.tags)

            val storedRecipeId = databaseRepository.addRecipe(
                recipe = generatedRecipe.toRecipe(
                    authorId = authRepository.currentUser?.uid.orEmpty(),
                    imageUri = recipeImageUri
                )
            )

            _viewState.value = _viewState.value.copy(
                recipeLoading = false
            )

            openRecipeScreen(storedRecipeId)
        }
    }

    private fun RecipeSchema.toRecipe(authorId: String, imageUri: String?): Recipe {
        return Recipe(
            title = title,
            instructions = instructions,
            ingredients = ingredients,
            authorId = authorId,
            tags = tags,
            prepTime = prepTime,
            cookTime = cookTime,
            servings = servings,
            imageUri = imageUri
        )
    }
}