package com.google.firebase.example.makeitso.ui.newTask

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import kotlinx.serialization.Serializable

@Serializable
object NewTaskRoute

@Composable
fun NewTaskScreen(
    viewModel: NewTaskViewModel = hiltViewModel(),
    navigateBack: () -> Unit
) {
    NewTaskScreenContent(
        navigateBack = navigateBack
    )
}

@Composable
fun NewTaskScreenContent(
    navigateBack: () -> Unit
) {

}

@Composable
@Preview
fun NewTaskScreenPreview() {
    MakeItSoTheme {
        NewTaskScreenContent {}
    }
}