package com.google.firebase.example.makeitso.ui.lists

import com.google.firebase.example.makeitso.MainViewModel
import com.google.firebase.example.makeitso.data.model.TaskList
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.emptyFlow
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject

@HiltViewModel
class ListsViewModel @Inject constructor(
    private val authRepository: AuthRepository,
    private val databaseRepository: DatabaseRepository,
    private val auth: FirebaseAuth
) : MainViewModel() {
    val currentUser = callbackFlow {
        val listener = FirebaseAuth.IdTokenListener { 
            trySend(it.currentUser)
        }
        auth.addIdTokenListener(listener)
        trySend(auth.currentUser)
        awaitClose { auth.removeIdTokenListener(listener) }
    }

    val lists = currentUser.flatMapLatest { user ->
        if (user != null) {
            databaseRepository.getLists(user.uid)
        } else {
            emptyFlow()
        }
    }

    init {
        launchCatching {
            if (authRepository.currentUser == null) {
                authRepository.createAnonymousAccount()
            }
        }
    }

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
