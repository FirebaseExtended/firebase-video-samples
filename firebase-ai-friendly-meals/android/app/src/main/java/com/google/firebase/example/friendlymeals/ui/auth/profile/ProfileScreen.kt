package com.google.firebase.example.friendlymeals.ui.auth.profile

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.google.firebase.example.friendlymeals.ui.auth.AuthViewState
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme

@Composable
fun ProfileScreenContent(
    viewState: AuthViewState
) {
    //TODO: create profile screen
    //TODO: enable user to update display name (used in filter screen)
}

@Preview
@Composable
fun ProfileScreenPreview() {
    FriendlyMealsTheme {
        ProfileScreenContent(
            viewState = AuthViewState()
        )
    }
}
