package com.notes.app.screens.authentication

import android.content.Context
import android.util.Log
import androidx.credentials.Credential
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption
import com.notes.app.ERROR_TAG
import com.notes.app.R
import com.notes.app.SnackbarManager
import com.notes.app.screens.NotesAppViewModel

open class AuthenticationViewModel : NotesAppViewModel() {
  suspend fun launchCredManButtonUI(
    context: Context,
    onRequestResult: (Credential) -> Unit
  ) {
    try {
      val signInWithGoogleOption = GetSignInWithGoogleOption
        .Builder(serverClientId = context.getString(R.string.default_web_client_id))
        .build()

      val request = GetCredentialRequest.Builder()
        .addCredentialOption(signInWithGoogleOption)
        .build()

      val result = CredentialManager.create(context).getCredential(
        request = request,
        context = context
      )

      onRequestResult(result.credential)
    } catch (e: NoCredentialException) {
      Log.d(ERROR_TAG, e.message.orEmpty())
      SnackbarManager.showMessage(context.getString(R.string.no_accounts_error))
    } catch (e: GetCredentialException) {
      Log.d(ERROR_TAG, e.message.orEmpty())
    }
  }

  suspend fun launchCredManBottomSheet(
    context: Context,
    hasFilter: Boolean = true,
    onRequestResult: (Credential) -> Unit
  ) {
    try {
      val googleIdOption = GetGoogleIdOption.Builder()
        .setFilterByAuthorizedAccounts(hasFilter)
        .setServerClientId(context.getString(R.string.default_web_client_id))
        .build()

      val request = GetCredentialRequest.Builder()
        .addCredentialOption(googleIdOption)
        .build()

      val result = CredentialManager.create(context).getCredential(
        request = request,
        context = context
      )

      onRequestResult(result.credential)
    } catch (e: NoCredentialException) {
      Log.d(ERROR_TAG, e.message.orEmpty())

      if (hasFilter) {
        launchCredManBottomSheet(context, hasFilter = false, onRequestResult)
      }
    } catch (e: GetCredentialException) {
      Log.d(ERROR_TAG, e.message.orEmpty())
    }
  }
}
