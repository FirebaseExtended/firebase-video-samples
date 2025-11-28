package com.google.firebase.example.friendlymeals.ui.scanMeal

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class ScanMealViewModel @Inject constructor() : MainViewModel() {
    private val _viewState = MutableStateFlow(ScanMealViewState())
    val viewState: StateFlow<ScanMealViewState>
        get() = _viewState.asStateFlow()

    fun onImageTaken(image: Bitmap?) {
        launchCatching {
            if (image != null) {
                _viewState.value = _viewState.value.copy(
                    scanLoading = true,
                    image = image,
                )

                //TODO: Use Gemini to generate nutritional facts

                _viewState.value = _viewState.value.copy(
                    scanLoading = false,
                    protein = "30g",
                    fat = "10g",
                    carbs = "80g",
                    sugar = "20g",
                    ingredients = listOf("Salmon Fillet", "Asparagus", "Lemon Slices", "Olive Oil")
                )

                //TODO: Update screen with image taken and nutritional facts
            }
        }
    }
}