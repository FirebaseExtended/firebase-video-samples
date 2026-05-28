package com.google.firebase.example.makeitso.ui.newTask

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.repository.AITaskService
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class NewTaskViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val databaseRepository: DatabaseRepository,
    private val authRepository: AuthRepository,
    private val aiTaskService: AITaskService
) : MainViewModel() {
    private val route = savedStateHandle.toRoute<NewTaskRoute>()

    var isAnalyzing = mutableStateOf(false)
        private set

    val generatedSubtasks = mutableStateListOf<String>()
        private set

    fun breakDownTask(title: String) {
        launchCatching {
            isAnalyzing.value = true
            generatedSubtasks.clear()
            try {
                val suggestions = aiTaskService.breakDownTask(title)
                generatedSubtasks.addAll(suggestions)
            } finally {
                isAnalyzing.value = false
            }
        }
    }

    fun saveTask(task: Task, navigateBack: () -> Unit) {
        launchCatching {
            android.util.Log.d("NewTaskViewModel", "Saving task with listId: ${route.listId}")
            val taskWithUserId = task.copy(
                userId = authRepository.currentUser?.uid,
                listId = route.listId
            )
            databaseRepository.saveTask(taskWithUserId)

            navigateBack()
        }
    }

    fun saveMultipleTasks(tasks: List<Task>, navigateBack: () -> Unit) {
        launchCatching {
            android.util.Log.d("NewTaskViewModel", "Saving multiple tasks with listId: ${route.listId}")
            tasks.forEach { task ->
                val taskWithUserId = task.copy(
                    userId = authRepository.currentUser?.uid,
                    listId = route.listId
                )
                databaseRepository.saveTask(taskWithUserId)
            }
            navigateBack()
        }
    }
}