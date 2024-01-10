package com.notes.app.screens.account_center

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.notes.app.R

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun DisplayNameCard(displayName: String, onUpdateDisplayNameClick: (String) -> Unit) {
    var showDisplayNameDialog by remember { mutableStateOf(false) }
    var newDisplayName by remember { mutableStateOf(displayName) }

    val cardTitle = displayName.ifBlank { stringResource(R.string.profile_name) }

    AccountCenterCard(cardTitle, Icons.Filled.Edit, Modifier.card()) {
        showDisplayNameDialog = true
    }

    if (showDisplayNameDialog) {
        AlertDialog(
            title = { Text(stringResource(R.string.profile_name)) },
            text = {
                Column {
                    TextField(
                        value = newDisplayName,
                        onValueChange = { newDisplayName = it }
                    )
                }
            },
            dismissButton = {
                Button(onClick = {
                    showDisplayNameDialog = false
                    newDisplayName = displayName
                }) {
                    Text(text = stringResource(R.string.cancel))
                }
            },
            confirmButton = {
                Button(onClick = {
                    onUpdateDisplayNameClick(newDisplayName)
                    showDisplayNameDialog = false
                }) {
                    Text(text = stringResource(R.string.update))
                }
            },
            onDismissRequest = {
                showDisplayNameDialog = false
                newDisplayName = displayName
            }
        )
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun AccountCenterCard(
    title: String,
    icon: ImageVector,
    modifier: Modifier = Modifier,
    onCardClick: () -> Unit
) {
    Card(
        modifier = modifier,
        onClick = onCardClick
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Column(modifier = Modifier.weight(1f)) { Text(title) }
            Icon(icon, contentDescription = "Icon")
        }
    }
}

fun Modifier.card(): Modifier {
    return this.padding(16.dp, 0.dp, 16.dp, 8.dp)
}

@Composable
fun ExitAppCard(onSignOutClick: () -> Unit) {
    var showExitAppDialog by remember { mutableStateOf(false) }

    AccountCenterCard(stringResource(R.string.sign_out), Icons.Filled.ExitToApp, Modifier.card()) {
        showExitAppDialog = true
    }

    if (showExitAppDialog) {
        AlertDialog(
            title = { Text(stringResource(R.string.sign_out_title)) },
            text = { Text(stringResource(R.string.sign_out_description)) },
            dismissButton = {
                Button(onClick = { showExitAppDialog = false }) {
                    Text(text = stringResource(R.string.cancel))
                }
            },
            confirmButton = {
                Button(onClick = {
                    onSignOutClick()
                    showExitAppDialog = false
                }) {
                    Text(text = stringResource(R.string.sign_out))
                }
            },
            onDismissRequest = { showExitAppDialog = false }
        )
    }
}

@Composable
fun RemoveAccountCard(onRemoveAccountClick: () -> Unit) {
    var showRemoveAccDialog by remember { mutableStateOf(false) }

    AccountCenterCard(stringResource(R.string.delete_account), Icons.Filled.Delete, Modifier.card()) {
        showRemoveAccDialog = true
    }

    if (showRemoveAccDialog) {
        AlertDialog(
            title = { Text(stringResource(R.string.delete_account_title)) },
            text = { Text(stringResource(R.string.delete_account_description)) },
            dismissButton = {
                Button(onClick = { showRemoveAccDialog = false }) {
                    Text(text = stringResource(R.string.cancel))
                }
            },
            confirmButton = {
                Button(onClick = {
                    onRemoveAccountClick()
                    showRemoveAccDialog = false
                }) {
                    Text(text = stringResource(R.string.delete_account))
                }
            },
            onDismissRequest = { showRemoveAccDialog = false }
        )
    }
}
