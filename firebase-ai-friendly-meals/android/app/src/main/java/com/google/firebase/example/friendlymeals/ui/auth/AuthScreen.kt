package com.google.firebase.example.friendlymeals.ui.auth

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.credentials.Credential
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.ui.auth.profile.ProfileScreenContent
import com.google.firebase.example.friendlymeals.ui.auth.signIn.SignInScreenContent
import com.google.firebase.example.friendlymeals.ui.auth.signUp.SignUpScreenContent
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import kotlinx.serialization.Serializable

@Serializable
object AuthRoute

@Composable
fun AuthScreen(
    viewModel: AuthViewModel = hiltViewModel(),
    showSnackbar: (String) -> Unit = {}
) {
    val viewState = viewModel.viewState.collectAsStateWithLifecycle()

    AuthScreenContent(
        signInWithEmail = viewModel::signInWithEmail,
        signInWithGoogle = viewModel::signInWithGoogle,
        signUpWithEmail = viewModel::signUpWithEmail,
        signUpWithGoogle = viewModel::signUpWithGoogle,
        updateAuthState = viewModel::updateAuthState,
        updateEmail = viewModel::updateEmail,
        updatePassword = viewModel::updatePassword,
        showSnackbar = showSnackbar,
        viewState = viewState.value
    )
}

@Composable
fun AuthScreenContent(
    signInWithEmail: () -> Unit = {},
    signInWithGoogle: (Credential) -> Unit = {},
    signUpWithEmail: () -> Unit = {},
    signUpWithGoogle: (Credential) -> Unit = {},
    updateAuthState: (AuthState) -> Unit = {},
    updateEmail: (String) -> Unit = {},
    updatePassword: (String) -> Unit = {},
    showSnackbar: (String) -> Unit = {},
    viewState: AuthViewState
) {
    when (viewState.authState) {
        AuthState.SIGN_IN -> SignInScreenContent(
            signInWithEmail = signInWithEmail,
            signInWithGoogle = signInWithGoogle,
            updateAuthState = updateAuthState,
            updateEmail = updateEmail,
            updatePassword = updatePassword,
            showSnackbar = showSnackbar,
            viewState = viewState
        )
        AuthState.SIGN_UP -> SignUpScreenContent(
            signUpWithEmail = signUpWithEmail,
            signUpWithGoogle = signUpWithGoogle,
            updateAuthState = updateAuthState,
            updateEmail = updateEmail,
            updatePassword = updatePassword,
            showSnackbar = showSnackbar,
            viewState = viewState
        )
        AuthState.PROFILE -> ProfileScreenContent(
            viewState = viewState
        )
    }
}

@Preview
@Composable
fun AuthScreenPreview() {
    FriendlyMealsTheme {
        AuthScreenContent(
            viewState = AuthViewState()
        )
    }
}