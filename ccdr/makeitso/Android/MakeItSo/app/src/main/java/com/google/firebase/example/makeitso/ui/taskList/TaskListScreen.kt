package com.google.firebase.example.makeitso.ui.taskList

import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import kotlinx.serialization.Serializable

@Serializable
object TaskListRoute

@Composable
fun TaskListScreen(
    viewModel: TaskListViewModel = hiltViewModel(),
    openNewTaskScreen: () -> Unit
) {
    TaskListScreenContent(
        openNewTaskScreen = openNewTaskScreen
    )
}

@Composable
fun TaskListScreenContent(
    openNewTaskScreen: () -> Unit
) {

}

@Composable
@Preview
fun TaskListScreenPreview() {
    MakeItSoTheme {
        TaskListScreenContent {}
    }
}