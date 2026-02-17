package com.google.firebase.example.makeitso.ui.newTask

import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class NewTaskViewModel @Inject constructor(
    private val databaseRepository: DatabaseRepository,
    private val authRepository: AuthRepository
) : MainViewModel() {
    fun saveTask(task: Task, navigateBack: () -> Unit) {
        launchCatching {
            val taskWithUserId = task.copy(userId = authRepository.currentUser?.uid)
            databaseRepository.saveTask(taskWithUserId)

            navigateBack()
        }
    }
}