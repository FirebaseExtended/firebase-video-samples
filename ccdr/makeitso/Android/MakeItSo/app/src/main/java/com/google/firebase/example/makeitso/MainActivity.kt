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
import com.google.firebase.example.makeitso.ui.auth.AuthRoute
import com.google.firebase.example.makeitso.ui.auth.AuthScreen
import com.google.firebase.example.makeitso.ui.profile.ProfileRoute
import com.google.firebase.example.makeitso.ui.profile.ProfileScreen
import com.google.firebase.example.makeitso.ui.newTask.NewTaskRoute
import com.google.firebase.example.makeitso.ui.newTask.NewTaskScreen
import com.google.firebase.example.makeitso.ui.taskList.TaskListRoute
import com.google.firebase.example.makeitso.ui.taskList.TaskListScreen
import androidx.navigation.toRoute
import com.google.firebase.example.makeitso.ui.theme.DeepDark
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import dagger.hilt.android.AndroidEntryPoint
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.lifecycle.lifecycleScope
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreException
import com.google.firebase.functions.FirebaseFunctions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.net.URL
import com.google.firebase.example.makeitso.data.repository.AuthRepository
import com.google.firebase.example.makeitso.data.repository.DatabaseRepository
import javax.inject.Inject
import androidx.navigation.NavHostController

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    @Inject lateinit var authRepository: AuthRepository
    @Inject lateinit var databaseRepository: DatabaseRepository

    private var navController: NavHostController? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)


        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(TRANSPARENT)
        )

        setContent {
            val controller = rememberNavController()
            navController = controller

            MakeItSoTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = DeepDark
                ) {
                    Scaffold(
                        modifier = Modifier.fillMaxSize()
                    ) { innerPadding ->
                        NavHost(
                            navController = controller,
                            startDestination = ListsRoute,
                            modifier = Modifier.padding(innerPadding)
                        ) {
                            composable<ListsRoute> {
                                ListsScreen(
                                    openList = { listId ->
                                        controller.navigate(TaskListRoute(listId = listId))
                                    },
                                    openProfile = {
                                        controller.navigate(ProfileRoute)
                                    }
                                )
                            }
                            composable<ProfileRoute> {
                                ProfileScreen(
                                    openAuth = { controller.navigate(AuthRoute) },
                                    onBack = { controller.popBackStack() }
                                )
                            }
                            composable<AuthRoute> {
                                AuthScreen(
                                    onComplete = { controller.popBackStack(ListsRoute, false) }
                                )
                            }
                            composable<TaskListRoute> { backStackEntry ->
                                val route = backStackEntry.toRoute<TaskListRoute>()
                                TaskListScreen(
                                    openNewTaskScreen = {
                                        controller.navigate(NewTaskRoute(listId = route.listId)) {
                                            launchSingleTop = true
                                        }
                                    },
                                    navigateBack = { controller.popBackStack() }
                                )
                            }
                            composable<NewTaskRoute> {
                                NewTaskScreen(
                                    navigateBack = { controller.popBackStack() }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        android.util.Log.d("MainActivity", "handleIntent: action=${intent.action} data=${intent.data}")
        if (intent.action == Intent.ACTION_VIEW) {
            val data: Uri? = intent.data
            if (data != null && data.host == "makeitso-share.web.app" && data.pathSegments.contains("join")) {
                val listId = data.pathSegments.lastOrNull()
                val token = data.getQueryParameter("token")
                android.util.Log.d("MainActivity", "handleIntent: listId=$listId token=$token")
                if (listId != null && token != null) {
                    joinList(listId, token)
                }
            }
        }
    }

    private fun joinList(listId: String, token: String) {
        lifecycleScope.launch {
            try {
                val userId = authRepository.getOrCreateUser()
                android.util.Log.d("MainActivity", "User is signed in: uid=$userId")

                databaseRepository.joinList(listId, token, userId)

                withContext(Dispatchers.Main) {
                    Toast.makeText(this@MainActivity, "Successfully joined list!", Toast.LENGTH_SHORT).show()
                    navController?.navigate(TaskListRoute(listId = listId))
                }
            } catch (e: Exception) {
                if (e is FirebaseFirestoreException && e.code == FirebaseFirestoreException.Code.PERMISSION_DENIED) {
                    android.util.Log.d("MainActivity", "Permission denied, assuming already joined.")
                    withContext(Dispatchers.Main) {
                        navController?.navigate(TaskListRoute(listId = listId))
                    }
                } else {
                    e.printStackTrace()
                    android.util.Log.e("MainActivity", "Join list error", e)
                    withContext(Dispatchers.Main) {
                        Toast.makeText(this@MainActivity, "Error: ${e.message}", Toast.LENGTH_LONG).show()
                    }
                }
            }
        }
    }
}
