package com.notes.app.screens.notes_list

import com.notes.app.SPLASH_SCREEN
import com.notes.app.model.service.AccountService
import com.notes.app.model.service.StorageService
import com.notes.app.screens.NotesAppViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class NotesListViewModel @Inject constructor(
    private val accountService: AccountService,
    storageService: StorageService
) : NotesAppViewModel() {
    val notes = storageService.notes

    fun initialize(restartApp: (String) -> Unit) {
        launchCatching {
            accountService.currentUser.collect { user ->
                if (user == null) restartApp(SPLASH_SCREEN)
            }
        }
    }
}