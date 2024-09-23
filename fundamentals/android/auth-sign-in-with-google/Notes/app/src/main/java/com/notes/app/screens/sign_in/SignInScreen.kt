package com.notes.app.screens.sign_in

import android.content.Context
import android.util.Log
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.notes.app.ERROR_TAG
import com.notes.app.R
import com.notes.app.SnackbarManager
import com.notes.app.ui.theme.NotesTheme
import com.notes.app.ui.theme.Purple40
import kotlinx.coroutines.launch

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun SignInScreen(
    openScreen: (String) -> Unit,
    openAndPopUp: (String, String) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: SignInViewModel = hiltViewModel()
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    val email = viewModel.email.collectAsState()
    val password = viewModel.password.collectAsState()

    Column(
        modifier = modifier
            .fillMaxWidth()
            .fillMaxHeight()
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Image(
            painter = painterResource(id = R.mipmap.auth_image),
            contentDescription = "Auth image",
            modifier = modifier
                .fillMaxWidth()
                .padding(16.dp, 4.dp)
        )

        Spacer(modifier = Modifier
            .fillMaxWidth()
            .padding(12.dp))

        OutlinedTextField(
            singleLine = true,
            modifier = modifier
                .fillMaxWidth()
                .padding(16.dp, 4.dp)
                .border(
                    BorderStroke(width = 2.dp, color = Purple40),
                    shape = RoundedCornerShape(50)
                ),
            colors = TextFieldDefaults.textFieldColors(
                containerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent
            ),
            value = email.value,
            onValueChange = { viewModel.updateEmail(it) },
            placeholder = { Text(stringResource(R.string.email)) },
            leadingIcon = { Icon(imageVector = Icons.Default.Email, contentDescription = "Email") }
        )

        OutlinedTextField(
            singleLine = true,
            modifier = modifier
                .fillMaxWidth()
                .padding(16.dp, 4.dp)
                .border(
                    BorderStroke(width = 2.dp, color = Purple40),
                    shape = RoundedCornerShape(50)
                ),
            colors = TextFieldDefaults.textFieldColors(
                containerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent
            ),
            value = password.value,
            onValueChange = { viewModel.updatePassword(it) },
            placeholder = { Text(stringResource(R.string.password)) },
            leadingIcon = { Icon(imageVector = Icons.Default.Lock, contentDescription = "Email") },
            visualTransformation = PasswordVisualTransformation()
        )

        Spacer(modifier = Modifier
            .fillMaxWidth()
            .padding(12.dp))

        Button(
            onClick = { viewModel.onSignInClick(openAndPopUp) },
            colors = ButtonDefaults.buttonColors(containerColor = Purple40),
            modifier = modifier
                .fillMaxWidth()
                .padding(16.dp, 0.dp)
        ) {
            Text(
                text = stringResource(R.string.sign_in),
                fontSize = 16.sp,
                modifier = modifier.padding(0.dp, 6.dp)
            )
        }

        Spacer(modifier = Modifier
            .fillMaxWidth()
            .padding(4.dp))

        TextButton(onClick = { viewModel.onSignUpClick(openScreen) }) {
            Text(text = stringResource(R.string.sign_up_description), fontSize = 16.sp, color = Purple40)
        }

        Spacer(modifier = Modifier
            .fillMaxWidth()
            .padding(4.dp))

        Text(text = stringResource(R.string.or), fontSize = 16.sp, color = Purple40)

        Spacer(modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp))

        Button(
            onClick = {
                coroutineScope.launch {
                    getCredentials(openAndPopUp, viewModel, context, showSnackbarOnError = true)
                }
            },
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
                text = stringResource(R.string.authenticate_with_google),
                fontSize = 16.sp,
                modifier = Modifier.padding(0.dp, 6.dp)
            )
        }

        LaunchedEffect(true) {
            coroutineScope.launch {
                getCredentials(openAndPopUp, viewModel, context, showSnackbarOnError = false)
            }
        }
    }
}

private suspend fun getCredentials(
    openAndPopUp: (String, String) -> Unit,
    viewModel: SignInViewModel,
    context: Context,
    showSnackbarOnError: Boolean
) {
    try {
        val request = getCredentialRequest(
            setFilter = true,
            webClientId = context.getString(R.string.default_web_client_id)
        )

        val result = CredentialManager.create(context).getCredential(
            request = request,
            context = context
        )

        viewModel.onSignInWithGoogle(result.credential, openAndPopUp)
    } catch (e: NoCredentialException) {
        getCredentialsWithoutFilter(openAndPopUp, viewModel, context, showSnackbarOnError)
    } catch (e: GetCredentialException) {
        Log.d(ERROR_TAG, e.message.orEmpty())
    }
}

private suspend fun getCredentialsWithoutFilter(
    openAndPopUp: (String, String) -> Unit,
    viewModel: SignInViewModel,
    context: Context,
    showSnackbarOnError: Boolean
) {
    try {
        val request = getCredentialRequest(
            setFilter = false,
            webClientId = context.getString(R.string.default_web_client_id)
        )

        val result = CredentialManager.create(context).getCredential(
            request = request,
            context = context
        )

        viewModel.onSignUpWithGoogle(result.credential, openAndPopUp)
    } catch (e: GetCredentialException) {
        if (showSnackbarOnError) {
            SnackbarManager.showMessage(context.getString(R.string.authentication_error))
        }

        Log.d(ERROR_TAG, e.message.orEmpty())
    }
}

private fun getCredentialRequest(setFilter: Boolean, webClientId: String): GetCredentialRequest {
    val googleIdOption = GetGoogleIdOption.Builder()
        .setFilterByAuthorizedAccounts(setFilter)
        .setServerClientId(webClientId)
        .build()

    return GetCredentialRequest.Builder()
        .addCredentialOption(googleIdOption)
        .build()
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun AuthPreview() {
    NotesTheme {
        SignInScreen({}, { _, _ -> })
    }
}