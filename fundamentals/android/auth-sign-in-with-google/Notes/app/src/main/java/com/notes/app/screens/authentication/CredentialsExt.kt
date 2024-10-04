package com.notes.app.screens.authentication

import android.content.Context
import android.util.Log
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
import com.notes.app.ui.theme.Purple40
import kotlinx.coroutines.launch

@Composable
fun AuthenticationButton(buttonText: Int, onRequestResult: (Credential) -> Unit) {
  val context = LocalContext.current
  val coroutineScope = rememberCoroutineScope()

  Button(
    onClick = { coroutineScope.launch { launchCredManButtonUI(context, onRequestResult) } },
    colors = ButtonDefaults.buttonColors(containerColor = Purple40),
    modifier = Modifier
      .fillMaxWidth()
      .padding(16.dp, 0.dp)
  ) {
    Icon(
      painter = painterResource(id = R.drawable.google_g),
      modifier = Modifier.padding(horizontal = 16.dp),
      contentDescription = "Google logo"
    )

    Text(
      text = stringResource(buttonText),
      fontSize = 16.sp,
      modifier = Modifier.padding(0.dp, 6.dp)
    )
  }
}

private suspend fun launchCredManButtonUI(
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