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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthScreen(
    onComplete: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var isSignUp by remember { mutableStateOf(false) }
    val isLinking = viewModel.isAnonymous()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        if (isLinking) "Link Account" 
                        else if (isSignUp) "Sign Up" 
                        else "Sign In"
                    ) 
                }
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
                    if (isLinking) {
                        viewModel.onLinkAccountClick(email, password, onComplete)
                    } else if (isSignUp) {
                        viewModel.onSignUpClick(email, password, onComplete)
                    } else {
                        viewModel.onSignInClick(email, password, onComplete)
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = email.isNotEmpty() && password.isNotEmpty()
            ) {
                Text(
                    if (isLinking) "Link Account" 
                    else if (isSignUp) "Sign Up" 
                    else "Sign In"
                )
            }

            if (!isLinking) {
                TextButton(
                    onClick = { isSignUp = !isSignUp },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        if (isSignUp) "Already have an account? Sign In" 
                        else "Don't have an account? Sign Up"
                    )
                }
            }
        }
    }
}
