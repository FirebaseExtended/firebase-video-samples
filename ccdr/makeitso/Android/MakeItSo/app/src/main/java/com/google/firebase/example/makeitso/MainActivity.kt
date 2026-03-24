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
import android.content.Intent
import android.net.Uri
import androidx.lifecycle.lifecycleScope
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)


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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_VIEW) {
            val data: Uri? = intent.data
            if (data != null && data.host == "makeitso-share.web.app" && data.pathSegments.contains("join")) {
                val listId = data.pathSegments.lastOrNull()
                val token = data.getQueryParameter("token")
                if (listId != null && token != null) {
                    joinList(listId, token)
                }
            }
        }
    }

    private fun joinList(listId: String, token: String) {
        lifecycleScope.launch {
            try {
                val user = FirebaseAuth.getInstance().currentUser ?: return@launch
                val idTokenResult = user.getIdToken(false).await()
                val idToken = idTokenResult.token ?: return@launch
                
                withContext(Dispatchers.IO) {
                    val url = URL("https://us-central1-make-it-so-live-ccdr-01.cloudfunctions.net/joinList")
                    val connection = url.openConnection() as HttpURLConnection
                    connection.requestMethod = "POST"
                    connection.setRequestProperty("Content-Type", "application/json")
                    connection.setRequestProperty("Authorization", "Bearer $idToken")
                    connection.doOutput = true

                    val jsonParam = JSONObject()
                    val dataObj = JSONObject()
                    dataObj.put("listId", listId)
                    dataObj.put("shareToken", token)
                    jsonParam.put("data", dataObj)

                    connection.outputStream.use { os ->
                        val input = jsonParam.toString().toByteArray(Charsets.UTF_8)
                        os.write(input, 0, input.size)
                    }

                    val code = connection.responseCode
                    if (code != 200) {
                        println("Join list failed code: $code")
                    } else {
                        println("Successfully joined list!")
                    }
                    connection.disconnect()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
