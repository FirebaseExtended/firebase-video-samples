package com.notes.app.screens.account_center

import android.annotation.SuppressLint
import androidx.annotation.StringRes
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBox
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.AddCircle
import androidx.compose.material.icons.filled.Create
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Face
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.notes.app.R
import com.notes.app.ui.theme.NotesTheme

@Composable
@OptIn(ExperimentalMaterial3Api::class)
@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
fun AccountCenterScreen(
    restartApp: (String) -> Unit,
    modifier: Modifier = Modifier,
    viewModel: AccountCenterViewModel = hiltViewModel()
) {
    val isAnonymousAccount = viewModel.isAnonymousAccount.collectAsState()

    Scaffold {
        Column(
            modifier = modifier
                .fillMaxWidth()
                .fillMaxHeight(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            TopAppBar(title = { Text(stringResource(R.string.account_center)) })

            Spacer(modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp))

            if (isAnonymousAccount.value) {
                AccountCenterCard(R.string.sign_in, Icons.Filled.Face, Modifier.card()) {
                    viewModel.onSignInClick(restartApp)
                }

                AccountCenterCard(R.string.sign_up, Icons.Filled.AccountCircle, Modifier.card()) {
                    viewModel.onSignUpClick(restartApp)
                }
            } else {
                ExitAppCard { viewModel.onSignOutClick(restartApp) }
                RemoveAccountCard { viewModel.onDeleteAccountClick(restartApp) }
            }
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun AccountCenterCard(
    @StringRes title: Int,
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
            Column(modifier = Modifier.weight(1f)) { Text(stringResource(title)) }
            Icon(icon, contentDescription = "Icon")
        }
    }
}

private fun Modifier.card(): Modifier {
    return this.padding(16.dp, 0.dp, 16.dp, 8.dp)
}

@Composable
private fun ExitAppCard(onSignOutClick: () -> Unit) {
    var showExitAppDialog by remember { mutableStateOf(false) }

    AccountCenterCard(R.string.sign_out, Icons.Filled.ExitToApp, Modifier.card()) {
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
private fun RemoveAccountCard(onRemoveAccountClick: () -> Unit) {
    var showRemoveAccDialog by remember { mutableStateOf(false) }

    AccountCenterCard(R.string.delete_account, Icons.Filled.Delete, Modifier.card()) {
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

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun AccountCenterPreview() {
    NotesTheme {
        AccountCenterScreen({ })
    }
}