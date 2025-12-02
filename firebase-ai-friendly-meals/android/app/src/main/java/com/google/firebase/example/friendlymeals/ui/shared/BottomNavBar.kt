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
import androidx.compose.ui.res.stringResource
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.auth.AuthRoute
import com.google.firebase.example.friendlymeals.ui.generate.GenerateRoute
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListRoute
import com.google.firebase.example.friendlymeals.ui.scanMeal.ScanMealRoute
import com.google.firebase.example.friendlymeals.ui.theme.Teal

sealed class BottomNavItem(val route: Any, val icon: Int, val label: Int) {
    object ScanMeal : BottomNavItem(ScanMealRoute, R.drawable.ic_camera, R.string.nav_bar_scan_meal)
    object Generate : BottomNavItem(GenerateRoute, R.drawable.ic_generate, R.string.nav_bar_generate)
    object RecipeList : BottomNavItem(RecipeListRoute, R.drawable.ic_dine, R.string.nav_bar_recipe_list)
    object Auth : BottomNavItem(AuthRoute, R.drawable.ic_account, R.string.nav_bar_auth)
}

@Composable
fun BottomNavBar(navigateTo: (Any) -> Unit) {
    var selectedItemIndex by remember { mutableIntStateOf(1) }

    val items = listOf(
        BottomNavItem.ScanMeal,
        BottomNavItem.Generate,
        BottomNavItem.RecipeList,
        BottomNavItem.Auth
    )

    NavigationBar {
        items.forEachIndexed { index, item ->
            val label = stringResource(item.label)

            NavigationBarItem(
                selected = selectedItemIndex == index,
                onClick = {
                    selectedItemIndex = index
                    navigateTo(item.route)
                },
                icon = { Icon(
                    painter = painterResource(item.icon),
                    contentDescription = label
                ) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = Teal,
                    indicatorColor = Color.Transparent,
                    selectedTextColor = Teal
                ),
                label = { Text(label) }
            )
        }
    }
}
