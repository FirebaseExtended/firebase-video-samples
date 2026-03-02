package com.google.firebase.example.makeitso.ui.newTask

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class NewTaskViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val databaseRepository: DatabaseRepository,
    private val authRepository: AuthRepository
) : MainViewModel() {
    private val route = savedStateHandle.toRoute<NewTaskRoute>()

    fun saveTask(task: Task, navigateBack: () -> Unit) {
        launchCatching {
            val taskWithUserId = task.copy(
                userId = authRepository.currentUser?.uid,
                listId = route.listId
            )
            databaseRepository.saveTask(taskWithUserId)

            navigateBack()
        }
    }
}