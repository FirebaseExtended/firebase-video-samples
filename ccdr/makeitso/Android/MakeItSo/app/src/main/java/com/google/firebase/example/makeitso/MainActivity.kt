package com.google.firebase.example.makeitso

import android.graphics.Color.TRANSPARENT
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.google.firebase.example.makeitso.ui.lists.ListsRoute
import com.google.firebase.example.makeitso.ui.lists.ListsScreen
import com.google.firebase.example.makeitso.ui.newTask.NewTaskRoute
import com.google.firebase.example.makeitso.ui.newTask.NewTaskScreen
import com.google.firebase.example.makeitso.ui.taskList.TaskListRoute
import com.google.firebase.example.makeitso.ui.taskList.TaskListScreen
import androidx.navigation.toRoute
import com.google.firebase.example.makeitso.ui.theme.DeepDark
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(TRANSPARENT)
        )

        setContent {
            val navController = rememberNavController()

            MakeItSoTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = DeepDark
                ) {
                    Scaffold(
                        modifier = Modifier.fillMaxSize()
                    ) { innerPadding ->
                        NavHost(
                            navController = navController,
                            startDestination = ListsRoute,
                            modifier = Modifier.padding(innerPadding)
                        ) {
                            composable<ListsRoute> {
                                ListsScreen(
                                    openList = { listId ->
                                        navController.navigate(TaskListRoute(listId = listId))
                                    }
                                )
                            }
                            composable<TaskListRoute> { backStackEntry ->
                                val route = backStackEntry.toRoute<TaskListRoute>()
                                TaskListScreen(
                                    openNewTaskScreen = {
                                        navController.navigate(NewTaskRoute(listId = route.listId)) {
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
}
