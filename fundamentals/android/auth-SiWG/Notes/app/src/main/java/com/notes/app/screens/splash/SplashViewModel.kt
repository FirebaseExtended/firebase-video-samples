package com.notes.app.screens.splash

import com.notes.app.NOTES_LIST_SCREEN
import com.notes.app.SPLASH_SCREEN
import com.notes.app.model.service.AccountService
import com.notes.app.screens.NotesAppViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class SplashViewModel @Inject constructor(
  private val accountService: AccountService
) : NotesAppViewModel() {

  fun onAppStart(openAndPopUp: (String, String) -> Unit) {
    if (accountService.hasUser()) openAndPopUp(NOTES_LIST_SCREEN, SPLASH_SCREEN)
    else createAnonymousAccount(openAndPopUp)
  }

  private fun createAnonymousAccount(openAndPopUp: (String, String) -> Unit) {
    launchCatching {
      accountService.createAnonymousAccount()
      openAndPopUp(NOTES_LIST_SCREEN, SPLASH_SCREEN)
    }
  }
}
