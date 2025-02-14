package com.google.firebase.example.friendlymeals.ui.home

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import kotlinx.serialization.Serializable

@Serializable
object HomeRoute

@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    HomeScreenContent()
}

@Composable
fun HomeScreenContent() {

}


@Composable
@Preview(showSystemUi = true)
fun HomeScreenPreview() {
    FriendlyMealsTheme(darkTheme = true) {
        HomeScreenContent()
    }
}