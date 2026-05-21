package com.google.firebase.example.makeitso.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import kotlinx.serialization.Serializable

@Serializable
object AuthRoute

enum class AuthMode {
    LINK, SIGN_IN, SIGN_UP
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthScreen(
    onComplete: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    val isAnonymous = viewModel.isAnonymous()
    var mode by remember { mutableStateOf(if (isAnonymous) AuthMode.LINK else AuthMode.SIGN_IN) }

    val titleText = when (mode) {
        AuthMode.LINK -> "Link Account"
        AuthMode.SIGN_IN -> "Sign In"
        AuthMode.SIGN_UP -> "Sign Up"
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(titleText) }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .fillMaxSize()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            TextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email") },
                modifier = Modifier.fillMaxWidth()
            )

            TextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password") },
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier.fillMaxWidth()
            )

            Button(
                onClick = {
                    when (mode) {
                        AuthMode.LINK -> viewModel.onLinkAccountClick(email, password, onComplete)
                        AuthMode.SIGN_UP -> viewModel.onSignUpClick(email, password, onComplete)
                        AuthMode.SIGN_IN -> viewModel.onSignInClick(email, password, onComplete)
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = email.isNotEmpty() && password.isNotEmpty()
            ) {
                Text(titleText)
            }

            if (isAnonymous) {
                when (mode) {
                    AuthMode.LINK -> {
                        TextButton(
                            onClick = { mode = AuthMode.SIGN_IN },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("Already have an account? Sign In")
                        }
                    }
                    AuthMode.SIGN_IN -> {
                        Column {
                            TextButton(
                                onClick = { mode = AuthMode.SIGN_UP },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Don't have an account? Sign Up")
                            }
                            TextButton(
                                onClick = { mode = AuthMode.LINK },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Link this session instead? Link Account")
                            }
                        }
                    }
                    AuthMode.SIGN_UP -> {
                        Column {
                            TextButton(
                                onClick = { mode = AuthMode.SIGN_IN },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Already have an account? Sign In")
                            }
                            TextButton(
                                onClick = { mode = AuthMode.LINK },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Link this session instead? Link Account")
                            }
                        }
                    }
                }
            } else {
                TextButton(
                    onClick = { 
                        mode = if (mode == AuthMode.SIGN_UP) AuthMode.SIGN_IN else AuthMode.SIGN_UP 
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        if (mode == AuthMode.SIGN_UP) "Already have an account? Sign In" 
                        else "Don't have an account? Sign Up"
                    )
                }
            }
        }
    }
}
