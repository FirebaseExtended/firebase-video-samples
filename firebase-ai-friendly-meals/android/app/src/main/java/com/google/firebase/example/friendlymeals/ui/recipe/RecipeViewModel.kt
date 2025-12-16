package com.google.firebase.example.friendlymeals.ui.recipe

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.data.model.Review
import com.google.firebase.example.friendlymeals.data.model.Save
import com.google.firebase.example.friendlymeals.data.repository.AuthRepository
import com.google.firebase.example.friendlymeals.data.repository.DatabaseRepository
import com.google.firebase.example.friendlymeals.data.repository.StorageRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class RecipeViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val authRepository: AuthRepository,
    private val storageRepository: StorageRepository,
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {
    private val recipeRoute = savedStateHandle.toRoute<RecipeRoute>()
    private val recipeId: String = recipeRoute.recipeId

    private val _recipeViewState = MutableStateFlow(RecipeViewState())
    val recipeViewState: StateFlow<RecipeViewState>
        get() = _recipeViewState.asStateFlow()

    val userId: String get() = authRepository.currentUser?.uid.orEmpty()

    fun loadRecipe() {
        launchCatching {
            _recipeViewState.value = RecipeViewState(
                recipe = databaseRepository.getRecipe(recipeId) ?: Recipe(),
                recipeImage = storageRepository.getImage(recipeId),
                saved = databaseRepository.getFavorite(userId, recipeId),
                rating = databaseRepository.getReview(userId, recipeId)
            )
        }
    }

    fun toggleFavorite() {
        launchCatching {
            val currentValue = _recipeViewState.value.saved
            _recipeViewState.value = _recipeViewState.value.copy(saved = !currentValue)
            databaseRepository.setFavorite(
                Save(
                    recipeId = recipeId,
                    userId = userId,
                    isFavorite = !currentValue
                )
            )

        }
    }

    fun leaveReview(rating: Int) {
        launchCatching {
            _recipeViewState.value = _recipeViewState.value.copy(rating = rating)
            databaseRepository.setReview(
                Review(
                    userId = userId,
                    recipeId = recipeId,
                    rating = rating
                )
            )
        }
    }
}