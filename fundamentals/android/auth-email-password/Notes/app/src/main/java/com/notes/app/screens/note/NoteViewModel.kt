package com.notes.app.screens.note

import com.notes.app.NOTE_DEFAULT_ID
import com.notes.app.SPLASH_SCREEN
import com.notes.app.model.Note
import com.notes.app.model.service.AccountService
import com.notes.app.model.service.StorageService
import com.notes.app.screens.NotesAppViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import javax.inject.Inject

@HiltViewModel
class NoteViewModel @Inject constructor(
    private val accountService: AccountService,
    private val storageService: StorageService
) : NotesAppViewModel() {
    val note = MutableStateFlow(DEFAULT_NOTE)

    fun initialize(noteId: String, restartApp: (String) -> Unit) {
        launchCatching {
            note.value = storageService.readNote(noteId) ?: DEFAULT_NOTE
        }

        observeAuthenticationState(restartApp)
    }

    private fun observeAuthenticationState(restartApp: (String) -> Unit) {
        launchCatching {
            accountService.currentUser.collect { user ->
                if (user == null) restartApp(SPLASH_SCREEN)
            }
        }
    }

    fun updateNote(newText: String) {
        note.value = note.value.copy(text = newText)
    }

    fun saveNote(popUpScreen: () -> Unit) {
        launchCatching {
            if (note.value.id == NOTE_DEFAULT_ID) {
                storageService.createNote(note.value)
            } else {
                storageService.updateNote(note.value)
            }
        }

        popUpScreen()
    }

    fun deleteNote(popUpScreen: () -> Unit) {
        launchCatching {
            storageService.deleteNote(note.value.id)
        }

        popUpScreen()
    }

    companion object {
        private val DEFAULT_NOTE = Note(NOTE_DEFAULT_ID, "My Note")
    }
}