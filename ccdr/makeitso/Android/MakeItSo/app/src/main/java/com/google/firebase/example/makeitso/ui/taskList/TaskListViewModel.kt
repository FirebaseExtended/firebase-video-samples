package com.google.firebase.example.makeitso.ui.taskList

import androidx.lifecycle.SavedStateHandle
import androidx.navigation.toRoute
import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

@HiltViewModel
class TaskListViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val authRepository: AuthRepository,
    private val databaseRepository: DatabaseRepository,
    private val auth: FirebaseAuth
) : MainViewModel() {
    private val route = savedStateHandle.toRoute<TaskListRoute>()

    private val _currentUser = callbackFlow {
        val listener = FirebaseAuth.IdTokenListener { 
            trySend(it.currentUser)
        }
        auth.addIdTokenListener(listener)
        trySend(auth.currentUser)
        awaitClose { auth.removeIdTokenListener(listener) }
    }

    val tasks = _currentUser.flatMapLatest { user ->
        if (user != null) {
            databaseRepository.getTasks(user.uid, route.listId)
        } else {
            emptyFlow()
        }
    }

    init {
        launchCatching {
            android.util.Log.d("TaskListViewModel", "init: checking currentUser")
            if (authRepository.currentUser == null) {
                android.util.Log.d("TaskListViewModel", "init: currentUser is null, creating anonymous account")
                authRepository.createAnonymousAccount()
            } else {
                android.util.Log.d("TaskListViewModel", "init: currentUser is ${authRepository.currentUser?.uid}")
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