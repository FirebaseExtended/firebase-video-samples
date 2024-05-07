package com.notes.app.screens.note

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Done
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.notes.app.model.getTitle
import com.notes.app.ui.theme.NotesTheme

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun NoteScreen(
    noteId: String,
    popUpScreen: () -> Unit,
    restartApp: (String) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: NoteViewModel = hiltViewModel()
) {
    val note = viewModel.note.collectAsState()

    LaunchedEffect(Unit) { viewModel.initialize(noteId, restartApp) }

    Column(modifier = Modifier
        .fillMaxWidth()
        .fillMaxHeight()) {
        TopAppBar(
            title = {
                Text(
                    text = note.value.getTitle(),
                    overflow = TextOverflow.Ellipsis,
                    softWrap = false,
                    maxLines = 1
                )
            },
            actions = {
                IconButton(onClick = { viewModel.saveNote(popUpScreen) }) {
                    Icon(Icons.Filled.Done, "Save note")
                }
                IconButton(onClick = { viewModel.deleteNote(popUpScreen) }) {
                    Icon(Icons.Filled.Delete, "Delete note")
                }
            }
        )

        Spacer(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp)
        )

        Column(
            modifier = modifier
                .fillMaxWidth()
                .fillMaxHeight()
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            TextField(
                value = note.value.text,
                onValueChange = { viewModel.updateNote(it) },
                modifier = modifier
                    .fillMaxWidth()
                    .wrapContentHeight(),
                colors = TextFieldDefaults.textFieldColors(
                    containerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent
                )
            )
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun NotePreview() {
    NotesTheme {
        NoteScreen(noteId = "1", {}, {})
    }
}