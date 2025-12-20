package com.google.firebase.example.friendlymeals

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.navigation.NavController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navigation
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.google.firebase.example.friendlymeals.ui.generate.GenerateRoute
import com.google.firebase.example.friendlymeals.ui.generate.GenerateScreen
import com.google.firebase.example.friendlymeals.ui.recipe.RecipeRoute
import com.google.firebase.example.friendlymeals.ui.recipe.RecipeScreen
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListGraph
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListRoute
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListScreen
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListViewModel
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterRoute
import com.google.firebase.example.friendlymeals.ui.recipeList.filter.FilterScreen
import com.google.firebase.example.friendlymeals.ui.scanMeal.ScanMealRoute
import com.google.firebase.example.friendlymeals.ui.scanMeal.ScanMealScreen
import com.google.firebase.example.friendlymeals.ui.shared.BottomNavBar
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setSoftInputMode()

        setContent {
            val snackbarHostState = remember { SnackbarHostState() }
            val navController = rememberNavController()

            FriendlyMealsTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background,
                ) {
                    Scaffold(
                        modifier = Modifier.fillMaxSize(),
                        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
                        bottomBar = { BottomNavBar { navigateTo(navController, route = it) } }
                    ) { innerPadding ->
                        NavHost(
                            navController = navController,
                            startDestination = GenerateRoute,
                            modifier = Modifier.padding(innerPadding)
                        ) {
                            composable<ScanMealRoute> { ScanMealScreen() }
                            composable<GenerateRoute> { GenerateScreen(
                                openRecipeScreen = { recipeId ->
                                    navController.navigate(RecipeRoute(recipeId)) {
                                        launchSingleTop = true
                                    }
                                }
                            ) }
                            navigation<RecipeListGraph>(startDestination = RecipeListRoute) {
                                composable<RecipeListRoute> { backStackEntry ->
                                    val parentEntry = remember(backStackEntry) {
                                        navController.getBackStackEntry(RecipeListGraph)
                                    }
                                    val viewModel = hiltViewModel<RecipeListViewModel>(parentEntry)

                                    RecipeListScreen(
                                        viewModel = viewModel,
                                        openRecipeScreen = { recipeId ->
                                            navController.navigate(RecipeRoute(recipeId)) {
                                                launchSingleTop = true
                                            }
                                        },
                                        openFilterScreen = {
                                            navController.navigate(FilterRoute) {
                                                launchSingleTop = true
                                            }
                                        }
                                    )
                                }
                                composable<FilterRoute> { backStackEntry ->
                                    val parentEntry = remember(backStackEntry) {
                                        navController.getBackStackEntry(RecipeListGraph)
                                    }
                                    val viewModel = hiltViewModel<RecipeListViewModel>(parentEntry)

                                    FilterScreen(
                                        viewModel = viewModel,
                                        navigateBack = { navController.popBackStack() }
                                    )
                                }
                            }
                            composable<RecipeRoute> { RecipeScreen(
                                navigateBack = { navController.popBackStack() }
                            ) }
                        }
                    }
                }
            }
        }
    }

    private fun navigateTo(navController: NavController, route: Any) {
        navController.navigate(route) {
            popUpTo(navController.graph.startDestinationId) { saveState = true }
            launchSingleTop = true
            restoreState = true
        }
    }

    private fun setSoftInputMode() {
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING)
    }
}