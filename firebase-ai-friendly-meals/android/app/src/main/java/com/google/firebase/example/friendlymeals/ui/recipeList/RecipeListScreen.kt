package com.google.firebase.example.friendlymeals.ui.recipeList

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.ui.theme.BackgroundColor
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.SelectedStarColor
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import com.google.firebase.example.friendlymeals.ui.theme.UnselectedStarColor
import kotlinx.serialization.Serializable

@Serializable
object RecipeListRoute

@Composable
fun RecipeListScreen(
    viewModel: RecipeListViewModel = hiltViewModel(),
    openRecipeScreen: (String) -> Unit,
    openFilterScreen: () -> Unit
) {
    val recipes = viewModel.recipes.collectAsStateWithLifecycle()

    RecipeListScreenContent(
        openRecipeScreen = openRecipeScreen,
        openFilterScreen = openFilterScreen,
        recipes = recipes.value,
    )

    LaunchedEffect(true) {
        viewModel.loadRecipes()
    }
}

@Composable
fun RecipeListScreenContent(
    openRecipeScreen: (String) -> Unit = {},
    openFilterScreen: () -> Unit = {},
    recipes: List<Recipe>
) {
    Scaffold(
        topBar = {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(id = R.string.recipe_list_title),
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextColor
                )
                IconButton(onClick = { openFilterScreen() }) {
                    Icon(
                        painter = painterResource(R.drawable.ic_filter),
                        contentDescription = stringResource(id = R.string.recipe_list_filter_button_content_description),
                        tint = TextColor
                    )
                }
            }
        },
        containerColor = BackgroundColor
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            items(recipes) { recipe ->
                RecipeCard(openRecipeScreen = openRecipeScreen, recipe = recipe)
            }
        }
    }
}

@Composable
fun RecipeCard(
    openRecipeScreen: (String) -> Unit = {},
    recipe: Recipe
) {
    Card(
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier.fillMaxWidth().clickable { openRecipeScreen(recipe.id) }
    ) {
        Row(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(Color.LightGray)
            ) {
                val image = recipe.image?.asImageBitmap()

                if (image != null) {
                    Image(
                        bitmap = image,
                        contentDescription = stringResource(id = R.string.recipe_list_item_image_content_description),
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Image(
                        painter = painterResource(R.mipmap.ic_launcher_no_bg),
                        contentDescription = stringResource(id = R.string.recipe_list_app_icon_content_description),
                        modifier = Modifier.fillMaxSize()
                    )
                }
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column {
                Text(
                    text = recipe.title,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextColor,
                    lineHeight = 20.sp
                )

                Spacer(modifier = Modifier.height(8.dp))

                Row {
                    repeat(5) { index ->
                        Icon(
                            painter = painterResource(R.drawable.ic_star),
                            //TODO: Add ic_star_half when rating is not exact
                            contentDescription = null,
                            tint = if (index < recipe.averageRating) SelectedStarColor else UnselectedStarColor,
                            modifier = Modifier.size(16.dp)
                        )
                    }
                }
            }
        }
    }
}

@Preview
@Composable
fun RecipeListScreenPreview() {
    FriendlyMealsTheme {
        RecipeListScreenContent(
            recipes = listOf()
        )
    }
}
