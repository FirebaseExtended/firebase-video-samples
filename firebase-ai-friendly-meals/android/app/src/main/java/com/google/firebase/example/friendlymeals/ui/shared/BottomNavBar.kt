package com.google.firebase.example.friendlymeals.ui.shared

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.painterResource
import androidx.navigation.NavController
import androidx.navigation.compose.currentBackStackEntryAsState
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.generate.GenerateRoute
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListRoute
import com.google.firebase.example.friendlymeals.ui.scanMeal.ScanMealRoute

sealed class BottomNavItem(val route: Any, val icon: Int, val label: String) {
    object ScanMeal : BottomNavItem(ScanMealRoute, R.drawable.ic_camera, "Scan Meal")
    object Generate : BottomNavItem(GenerateRoute, R.drawable.ic_generate, "Generate")
    object Recipes : BottomNavItem(RecipeListRoute, R.drawable.ic_dine, "Recipes")
}

@Composable
fun BottomNavBar(navController: NavController) {
    val items = listOf(BottomNavItem.ScanMeal, BottomNavItem.Generate, BottomNavItem.Recipes)

    NavigationBar {
        val currentBackStackEntry = navController.currentBackStackEntryAsState().value
        val currentRoute = currentBackStackEntry?.destination?.route

        items.forEach { item ->
            val selected = currentRoute == item.route

            NavigationBarItem(
                selected = selected,
                onClick = {
                    if (currentRoute != item.route) {
                        navController.navigate(item.route) {
                            popUpTo(navController.graph.startDestinationId) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                },
                icon = { Icon(
                    painter = painterResource(item.icon),
                    contentDescription = item.label
                ) },
                label = { Text(item.label) }
            )
        }
    }
}