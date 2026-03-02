package com.google.firebase.example.makeitso.ui.taskList

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.emptyFlow
import javax.inject.Inject

@HiltViewModel
class TaskListViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val authRepository: AuthRepository,
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {
    private val route = savedStateHandle.toRoute<TaskListRoute>()

    val tasks = authRepository.currentUser?.let { user ->
        databaseRepository.getTasks(user.uid, route.listId)
    } ?: emptyFlow()

    init {
        launchCatching {
            if (authRepository.currentUser == null) {
                authRepository.createAnonymousAccount()
            }
        }
    }

    fun onTaskCheckChange(task: Task) {
        launchCatching {
            databaseRepository.updateTask(task.copy(isCompleted = !task.isCompleted))
        }
    }

    fun onDeleteTask(task: Task) {
        launchCatching {
            task.id.let {
                databaseRepository.deleteTask(it)
            }
        }
    }
}