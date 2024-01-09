package com.notes.app.screens.sign_up

import com.notes.app.NOTES_LIST_SCREEN
import com.notes.app.SIGN_UP_SCREEN
import com.notes.app.model.service.AccountService
import com.notes.app.screens.NotesAppViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class SignUpViewModel @Inject constructor(
    private val accountService: AccountService
) : NotesAppViewModel() {
    // Backing properties to avoid state updates from other classes
    private val _email = MutableStateFlow("")
    val email: StateFlow<String> = _email.asStateFlow()

    private val _password = MutableStateFlow("")
    val password: StateFlow<String> = _password.asStateFlow()

    private val _confirmPassword = MutableStateFlow("")
    val confirmPassword: StateFlow<String> = _confirmPassword.asStateFlow()

    fun updateEmail(newEmail: String) {
        _email.value = newEmail
    }

    fun updatePassword(newPassword: String) {
        _password.value = newPassword
    }

    fun updateConfirmPassword(newConfirmPassword: String) {
        _confirmPassword.value = newConfirmPassword
    }

    fun onSignUpClick(openAndPopUp: (String, String) -> Unit) {
        launchCatching {
            if (!_email.value.isValidEmail()) {
                throw Exception("Invalid email format")
            }

            if (!_password.value.isValidPassword()) {
                throw Exception("Invalid password format")
            }

            if (!_password.value.passwordMatches(_confirmPassword.value)) {
                throw Exception("Passwords do not match")
            }

            accountService.linkAccount(_email.value, _password.value)
            openAndPopUp(NOTES_LIST_SCREEN, SIGN_UP_SCREEN)
        }
    }
}