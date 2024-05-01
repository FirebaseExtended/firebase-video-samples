package com.notes.app.screens.account_center

import android.annotation.SuppressLint
import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Face
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.notes.app.R
import com.notes.app.model.User
import com.notes.app.ui.theme.NotesTheme
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.notes.app.ERROR_TAG
import kotlinx.coroutines.launch
import java.util.Locale

@Composable
@OptIn(ExperimentalMaterial3Api::class)
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
fun AccountCenterScreen(
    restartApp: (String) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AccountCenterViewModel = hiltViewModel()
) {
    val user by viewModel.user.collectAsState(initial = User())
    val provider = user.provider.replaceFirstChar { it.titlecase(Locale.getDefault()) }

    Scaffold {
        Column(
            modifier = modifier
                .fillMaxWidth()
                .fillMaxHeight(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            TopAppBar(title = { Text(stringResource(R.string.account_center)) })

            Spacer(modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp))

            DisplayNameCard(user.displayName) { viewModel.onUpdateDisplayNameClick(it) }

            Spacer(modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp))

            Card(modifier = Modifier.card()) {
                Column(modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 16.dp, start = 16.dp, end = 16.dp)) {
                    if (!user.isAnonymous) {
                        Text(
                            text = String.format(stringResource(R.string.profile_email), user.email),
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(bottom = 16.dp)
                        )
                    }

                    // ⚠️This is for demonstration purposes only, it's not a common
                    // practice to show the unique ID or account provider of an account⚠️
                    Text(
                        text = String.format(stringResource(R.string.profile_uid), user.id),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 16.dp)
                    )

                    Text(
                        text = String.format(stringResource(R.string.profile_provider), provider),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 16.dp)
                    )
                }
            }

            Spacer(modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp))

            if (user.isAnonymous) {
                CredentialManagerCard(restartApp)

                AccountCenterCard(stringResource(R.string.sign_in_with_email), Icons.Filled.Face, Modifier.card()) {
                    viewModel.onSignInClick(restartApp)
                }

                AccountCenterCard(stringResource(R.string.sign_up), Icons.Filled.AccountCircle, Modifier.card()) {
                    viewModel.onSignUpClick(restartApp)
                }
            } else {
                ExitAppCard { viewModel.onSignOutClick(restartApp) }
                RemoveAccountCard { viewModel.onDeleteAccountClick(restartApp) }
            }
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
fun CredentialManagerCard(
    restartApp: (String) -> Unit,
    viewModel: AccountCenterViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    val credentialManager = CredentialManager.create(context)

    Card(
        modifier = Modifier.card(),
        onClick = {
            val googleIdOption = GetGoogleIdOption.Builder()
                .setFilterByAuthorizedAccounts(false)
                .setServerClientId(context.getString(R.string.default_web_client_id))
                .build()

            val request = GetCredentialRequest
                .Builder()
                .addCredentialOption(googleIdOption)
                .build()

            coroutineScope.launch {
                try {
                    val result = credentialManager.getCredential(
                        request = request,
                        context = context
                    )

                    viewModel.onGetCredentialResponse(result, restartApp)
                } catch (e: GetCredentialException) {
                    Log.d(ERROR_TAG, e.message.orEmpty())
                }
            }
        }
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Column(modifier = Modifier.weight(1f)) { Text(stringResource(R.string.sign_in_with_google)) }
            Icon(ImageVector.vectorResource(R.drawable.google_g), contentDescription = "Icon")
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun AccountCenterPreview() {
    NotesTheme {
        AccountCenterScreen({ })
    }
}