package com.google.firebase.example.makeitso.ui.lists

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.List
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.google.firebase.example.makeitso.data.model.TaskList
import com.google.firebase.example.makeitso.ui.theme.CardBackground
import com.google.firebase.example.makeitso.ui.theme.HighlightBlue
import kotlinx.serialization.Serializable

@Serializable
object ListsRoute

@Composable
fun ListsScreen(
    openList: (String?) -> Unit,
    viewModel: ListsViewModel = hiltViewModel()
) {
    val lists by viewModel.lists.collectAsState(initial = emptyList())
    var showAddDialog by remember { mutableStateOf(false) }
    var newListTitle by remember { mutableStateOf("") }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        "My Lists", 
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontWeight = FontWeight.Bold
                        )
                    ) 
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.background
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddDialog = true },
                containerColor = HighlightBlue,
                contentColor = Color.White
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add List")
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .padding(paddingValues)
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item {
                ListCard(
                    title = "All Tasks",
                    onClick = { openList(null) }
                )
            }

            items(lists) { list ->
                ListCard(
                    title = list.title,
                    onClick = { openList(list.id) }
                )
            }
        }

        if (showAddDialog) {
            AlertDialog(
                onDismissRequest = { showAddDialog = false },
                title = { Text("New List") },
                text = {
                    TextField(
                        value = newListTitle,
                        onValueChange = { newListTitle = it },
                        placeholder = { Text("List Name") }
                    )
                },
                confirmButton = {
                    TextButton(
                        onClick = {
                            viewModel.onAddList(newListTitle)
                            newListTitle = ""
                            showAddDialog = false
                        },
                        enabled = newListTitle.isNotEmpty()
                    ) { Text("Add") }
                },
                dismissButton = {
                    TextButton(onClick = { showAddDialog = false }) { Text("Cancel") }
                }
            )
        }
    }
}

@Composable
fun ListCard(title: String, onClick: () -> Unit) {
    Card(
        onClick = onClick,
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = CardBackground),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Default.List, contentDescription = null, tint = HighlightBlue)
            Spacer(modifier = Modifier.width(16.dp))
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge.copy(
                    color = Color.White,
                    fontWeight = FontWeight.Medium
                )
            )
        }
    }
}
