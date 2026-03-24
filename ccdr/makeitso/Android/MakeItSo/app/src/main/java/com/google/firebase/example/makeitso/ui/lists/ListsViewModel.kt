package com.google.firebase.example.makeitso.ui.lists

import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.TaskList
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.emptyFlow
import javax.inject.Inject

@HiltViewModel
class ListsViewModel @Inject constructor(
    private val authRepository: AuthRepository,
    private val databaseRepository: DatabaseRepository
) : MainViewModel() {
    val lists = authRepository.currentUser?.let { user ->
        databaseRepository.getLists(user.uid)
    } ?: emptyFlow()

    fun onAddList(title: String) {
        launchCatching {
            val userId = authRepository.currentUser?.uid
            if (userId.isNullOrBlank()) return@launchCatching

            val list = TaskList(
                title = title,
                userId = userId,
                shareToken = java.util.UUID.randomUUID().toString()
            )
            databaseRepository.saveList(list)
        }
    }

    fun onDeleteList(listId: String) {
        launchCatching {
            databaseRepository.deleteList(listId)
        }
    }
}
