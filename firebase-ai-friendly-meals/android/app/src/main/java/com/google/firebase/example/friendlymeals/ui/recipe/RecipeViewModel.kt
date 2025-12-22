package com.google.firebase.example.friendlymeals.ui.recipe

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Review
import com.google.firebase.example.friendlymeals.data.model.Save
import com.google.firebase.example.friendlymeals.data.repository.AuthRepository
import com.google.firebase.example.friendlymeals.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class RecipeViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val authRepository: AuthRepository,
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {
    private val recipeRoute = savedStateHandle.toRoute<RecipeRoute>()
    private val recipeId: String = recipeRoute.recipeId

    private val _recipeViewState = MutableStateFlow(RecipeViewState())
    val recipeViewState: StateFlow<RecipeViewState>
        get() = _recipeViewState.asStateFlow()

    val userId: String get() = authRepository.currentUser?.uid.orEmpty()

    init {
        loadRecipe()
    }

    fun loadRecipe() {
        launchCatching {
            _recipeViewState.value = RecipeViewState(
                recipe = databaseRepository.getRecipe(recipeId) ?: Recipe(),
                favorite = loadFavorite(),
                rating = loadRating()
            )
        }
    }

    private suspend fun loadFavorite(): Boolean {
        return databaseRepository.getFavorite(userId, recipeId)
    }

    private suspend fun loadRating(): Int {
        return databaseRepository.getReview(userId, recipeId)
    }

    fun toggleFavorite() {
        val save = Save(
            recipeId = recipeId,
            userId = userId
        )

        launchCatching {
            if (_recipeViewState.value.favorite) {
                databaseRepository.removeFavorite(save)
            } else {
                databaseRepository.setFavorite(save)
            }

            _recipeViewState.value = _recipeViewState.value.copy(
                favorite = loadFavorite()
            )
        }
    }

    fun leaveReview(rating: Int) {
        launchCatching {
            databaseRepository.setReview(
                Review(
                    userId = userId,
                    recipeId = recipeId,
                    rating = rating
                )
            )

            _recipeViewState.value = _recipeViewState.value.copy(
                rating = loadRating()
            )
        }
    }
}