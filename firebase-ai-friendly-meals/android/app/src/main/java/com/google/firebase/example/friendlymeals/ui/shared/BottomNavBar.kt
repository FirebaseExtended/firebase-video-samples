package com.google.firebase.example.friendlymeals.ui.shared

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.generate.GenerateRoute
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListRoute
import com.google.firebase.example.friendlymeals.ui.scanMeal.ScanMealRoute
import com.google.firebase.example.friendlymeals.ui.theme.TealColor

sealed class BottomNavItem(val route: Any, val icon: Int, val label: String) {
    object ScanMeal : BottomNavItem(ScanMealRoute, R.drawable.ic_camera, "Scan Meal")
    object Generate : BottomNavItem(GenerateRoute, R.drawable.ic_generate, "Generate")
    object Recipes : BottomNavItem(RecipeListRoute, R.drawable.ic_dine, "Recipes")
}

@Composable
fun BottomNavBar(navigateTo: (Any) -> Unit) {
    var selectedItemIndex by remember { mutableIntStateOf(1) }
    val items = listOf(BottomNavItem.ScanMeal, BottomNavItem.Generate, BottomNavItem.Recipes)

    NavigationBar {
        items.forEachIndexed { index, item ->
            NavigationBarItem(
                selected = selectedItemIndex == index,
                onClick = {
                    selectedItemIndex = index
                    navigateTo(item.route)
                },
                icon = { Icon(
                    painter = painterResource(item.icon),
                    contentDescription = item.label
                ) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = TealColor,
                    indicatorColor = Color.Transparent,
                    selectedTextColor = TealColor
                ),
                label = { Text(item.label) }
            )
        }
    }
}
