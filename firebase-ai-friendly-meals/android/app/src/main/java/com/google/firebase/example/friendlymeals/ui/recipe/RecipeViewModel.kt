package com.google.firebase.example.friendlymeals.ui.recipe

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.friendlymeals.MainViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class RecipeViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle
) : MainViewModel() {
    private val recipeRoute = savedStateHandle.toRoute<RecipeRoute>()
    private val recipeId: String = recipeRoute.recipeId

    fun loadRecipe() {
        launchCatching {
            //_todoItem.value = repository.getRecipe(recipeId)
            //TODO: load recipe from database
        }
    }
}