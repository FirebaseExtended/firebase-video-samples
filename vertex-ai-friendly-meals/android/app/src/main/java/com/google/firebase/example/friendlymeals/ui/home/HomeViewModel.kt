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

    fun generateRecipe(ingredients: String, cuisines: String) {
        launchCatching {
            val generatedRecipe = aiRepository.generateRecipe(ingredients, cuisines)
            val recipeImage = aiRepository.generateRecipeImage(generatedRecipe)

            _recipe.value = Recipe(
                description = generatedRecipe,
                image = recipeImage
            )
        }
    }
}