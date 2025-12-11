package com.google.firebase.example.friendlymeals.ui.scanMeal

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.MainViewModel
import com.google.firebase.example.friendlymeals.data.repository.AIRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class ScanMealViewModel @Inject constructor(
    private val aiRepository: AIRepository
) : MainViewModel() {
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

                val mealBreakdown = aiRepository.scanMeal(image)

                _viewState.value = _viewState.value.copy(
                    scanLoading = false,
                    mealBreakdown = mealBreakdown
                )
            }
        }
    }
}