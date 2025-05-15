package com.google.firebase.example.friendlymeals.ui.home

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
    private val _recipe = MutableStateFlow<Recipe?>(null)
    val recipe: StateFlow<Recipe?>
        get() = _recipe.asStateFlow()

    private val _loading = MutableStateFlow(false)
    val loading: StateFlow<Boolean>
        get() = _loading.asStateFlow()

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