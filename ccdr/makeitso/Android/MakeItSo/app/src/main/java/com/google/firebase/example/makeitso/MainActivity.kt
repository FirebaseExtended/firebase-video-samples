package com.google.firebase.example.makeitso

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.google.firebase.example.makeitso.ui.newTask.NewTaskRoute
import com.google.firebase.example.makeitso.ui.newTask.NewTaskScreen
import com.google.firebase.example.makeitso.ui.taskList.TaskListRoute
import com.google.firebase.example.makeitso.ui.taskList.TaskListScreen
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setSoftInputMode()

        setContent {
            val navController = rememberNavController()

            MakeItSoTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    Scaffold(
                        modifier = Modifier.fillMaxSize()
                    ) { innerPadding ->
                        NavHost(
                            navController = navController,
                            startDestination = TaskListRoute,
                            modifier = Modifier.padding(innerPadding)
                        ) {
                            composable<TaskListRoute> {
                                TaskListScreen(
                                    openNewTaskScreen = {
                                        navController.navigate(NewTaskRoute) {
                                            launchSingleTop = true
                                        }
                                    }
                                )
                            }
                            composable<NewTaskRoute> {
                                NewTaskScreen(
                                    navigateBack = { navController.popBackStack() }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private fun setSoftInputMode() {
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
    }
}
