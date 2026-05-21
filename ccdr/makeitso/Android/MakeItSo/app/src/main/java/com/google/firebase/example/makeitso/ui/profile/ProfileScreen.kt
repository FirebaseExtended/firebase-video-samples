package com.google.firebase.example.makeitso.ui.profile

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import kotlinx.serialization.Serializable

@Serializable
object ProfileRoute

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    openAuth: () -> Unit,
    onBack: () -> Unit,
    viewModel: ProfileViewModel = hiltViewModel()
) {
    val currentUser by viewModel.currentUser.collectAsState(initial = null)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Profile") }
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
            Card(
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "User Information",
                        style = MaterialTheme.typography.titleLarge
                    )
                    
                    if (currentUser?.isAnonymous == true) {
                        Text("Anonymous User")
                        Text(
                            text = "ID: ${currentUser?.uid}",
                            style = MaterialTheme.typography.bodySmall
                        )
                    } else {
                        Text("Email: ${currentUser?.email}")
                        Text(
                            text = "ID: ${currentUser?.uid}",
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                }
            }

            if (currentUser?.isAnonymous == true || currentUser == null) {
                Button(
                    onClick = openAuth,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Sign In")
                }
            }

            if (currentUser != null && !currentUser!!.isAnonymous) {
                Button(
                    onClick = { viewModel.onSignOut(onBack) },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Sign Out")
                }
            }
        }
    }
}
