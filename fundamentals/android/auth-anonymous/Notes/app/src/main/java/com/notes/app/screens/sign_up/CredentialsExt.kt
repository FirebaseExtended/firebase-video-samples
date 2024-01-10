package com.notes.app.screens.sign_up

import android.util.Patterns
import java.util.regex.Pattern

// Passwords must have at least six digits and include
// one digit, one lower case letter and one upper case letter.
private const val MIN_PASS_LENGTH = 6
private const val PASS_PATTERN = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=\\S+$).{4,}$"

fun String.isValidEmail(): Boolean {
  return this.isNotBlank() && Patterns.EMAIL_ADDRESS.matcher(this).matches()
}

fun String.isValidPassword(): Boolean {
  return this.isNotBlank() &&
    this.length >= MIN_PASS_LENGTH &&
    Pattern.compile(PASS_PATTERN).matcher(this).matches()
}
