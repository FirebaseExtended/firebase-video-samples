package com.notes.app.screens.authentication

import android.content.Context
import android.util.Log
import androidx.credentials.Credential
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.notes.app.ERROR_TAG
import com.notes.app.R
import com.notes.app.SnackbarManager
import com.notes.app.screens.NotesAppViewModel

open class AuthenticationViewModel : NotesAppViewModel() {
  suspend fun launchCredentialManager(
    context: Context,
    showError: Boolean,
    onRequestResult: (Credential) -> Unit
  ) {
    try {
      val request = createCredentialRequest(
        hasFilter = true,
        webClientId = context.getString(R.string.default_web_client_id)
      )

      val result = CredentialManager.create(context).getCredential(
        request = request,
        context = context
      )

      onRequestResult(result.credential)
    } catch (e: NoCredentialException) {
      launchCredentialManagerWithoutFilter(context, showError, onRequestResult)
    } catch (e: GetCredentialException) {
      Log.d(ERROR_TAG, e.message.orEmpty())
    }
  }

  private suspend fun launchCredentialManagerWithoutFilter(
    context: Context,
    showError: Boolean,
    onRequestResult: (Credential) -> Unit
  ) {
    try {
      val request = createCredentialRequest(
        hasFilter = false,
        webClientId = context.getString(R.string.default_web_client_id)
      )

      val result = CredentialManager.create(context).getCredential(
        request = request,
        context = context
      )

      onRequestResult(result.credential)
    } catch (e: NoCredentialException) {
      if (showError) SnackbarManager.showMessage(context.getString(R.string.authentication_error))
    } catch (e: GetCredentialException) {
      Log.d(ERROR_TAG, e.message.orEmpty())
    }
  }

  private fun createCredentialRequest(hasFilter: Boolean, webClientId: String): GetCredentialRequest {
    val googleIdOption = GetGoogleIdOption.Builder()
      .setFilterByAuthorizedAccounts(hasFilter)
      .setServerClientId(webClientId)
      .build()

    return GetCredentialRequest.Builder()
      .addCredentialOption(googleIdOption)
      .build()
  }
}
