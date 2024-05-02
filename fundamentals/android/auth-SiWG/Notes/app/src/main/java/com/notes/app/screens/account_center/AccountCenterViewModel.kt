package com.notes.app.screens.account_center

import android.util.Log
import androidx.credentials.Credential
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialResponse
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential.Companion.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
import com.notes.app.ERROR_TAG
import com.notes.app.SIGN_IN_SCREEN
import com.notes.app.SIGN_UP_SCREEN
import com.notes.app.SPLASH_SCREEN
import com.notes.app.UNEXPECTED_CREDENTIAL
import com.notes.app.UNEXPECTED_CUSTOM_CREDENTIAL
import com.notes.app.model.User
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
    // Backing property to avoid state updates from other classes
    private val _user = MutableStateFlow(User())
    val user: StateFlow<User> = _user.asStateFlow()

    init {
        launchCatching {
            _user.value = accountService.getUserProfile()
        }
    }

    fun onUpdateDisplayNameClick(newDisplayName: String) {
        launchCatching {
            accountService.updateDisplayName(newDisplayName)
            _user.value = accountService.getUserProfile()
        }
    }

    fun onSignInClick(openScreen: (String) -> Unit) = openScreen(SIGN_UP_SCREEN)

    fun onGetCredentialResponse(result: GetCredentialResponse, openScreen: (String) -> Unit) {
        when (val credential = result.credential) {
            is CustomCredential -> {
                if (credential.type == TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
                    linkAccountWithGoogle(credential, openScreen)
                } else {
                    Log.d(ERROR_TAG, UNEXPECTED_CUSTOM_CREDENTIAL)
                }
            }
            else -> {
                Log.d(ERROR_TAG, UNEXPECTED_CREDENTIAL)
            }
        }
    }

    private fun linkAccountWithGoogle(credential: Credential, openScreen: (String) -> Unit) {
        launchCatching {
            val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
            accountService.linkAccountWithGoogle(googleIdTokenCredential.idToken)
            openScreen(SPLASH_SCREEN)
        }
    }

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