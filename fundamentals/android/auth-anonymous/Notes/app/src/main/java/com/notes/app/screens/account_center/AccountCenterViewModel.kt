package com.notes.app.screens.account_center

import com.notes.app.SIGN_IN_SCREEN
import com.notes.app.SIGN_UP_SCREEN
import com.notes.app.SPLASH_SCREEN
import com.notes.app.model.service.AccountService
import com.notes.app.screens.NotesAppViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class AccountCenterViewModel @Inject constructor(
    private val accountService: AccountService
) : NotesAppViewModel() {
    // Backing properties to avoid state updates from other classes
    private val _isAnonymousAccount = MutableStateFlow(true)
    val isAnonymousAccount: StateFlow<Boolean> = _isAnonymousAccount.asStateFlow()

    init {
        _isAnonymousAccount.value = accountService.isAnonymousUser()
    }

    fun onSignInClick(openScreen: (String) -> Unit) = openScreen(SIGN_IN_SCREEN)

    fun onSignUpClick(openScreen: (String) -> Unit) = openScreen(SIGN_UP_SCREEN)

    fun onSignOutClick(restartApp: (String) -> Unit) {
        launchCatching {
            accountService.signOut()
            restartApp(SPLASH_SCREEN)
        }
    }

    fun onDeleteAccountClick(restartApp: (String) -> Unit) {
        launchCatching {
            accountService.deleteAccount()
            restartApp(SPLASH_SCREEN)
        }
    }
}