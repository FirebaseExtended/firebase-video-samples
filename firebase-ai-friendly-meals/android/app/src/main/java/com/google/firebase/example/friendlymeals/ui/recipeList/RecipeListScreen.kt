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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.LightTeal
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
}

@Composable
fun RecipeListScreenContent(
    openRecipeScreen: (String) -> Unit = {},
    openFilterScreen: () -> Unit = {},
    recipes: List<RecipeListItem>
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
                    fontWeight = FontWeight.Bold
                )
                IconButton(onClick = { openFilterScreen() }) {
                    Icon(
                        painter = painterResource(R.drawable.ic_filter),
                        contentDescription = stringResource(id = R.string.recipe_list_filter_button_content_description)
                    )
                }
            }
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            items(items = recipes, key = { it.id} ) { recipe ->
                RecipeCard(openRecipeScreen = openRecipeScreen, recipe = recipe)
            }
        }
    }
}

@Composable
fun RecipeCard(
    openRecipeScreen: (String) -> Unit = {},
    recipe: RecipeListItem
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
                    .background(LightTeal)
            ) {
                if (recipe.imageUri != null) {
                    AsyncImage(
                        model = ImageRequest.Builder(LocalContext.current)
                            .data(recipe.imageUri)
                            .crossfade(true)
                            .build(),
                        contentDescription = stringResource(id = R.string.recipe_image_content_description),
                        placeholder = painterResource(R.mipmap.ic_launcher_no_bg),
                        contentScale = ContentScale.Crop,
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
                    for (index in 1..5) {
                        AverageRatingIcon(index, recipe.averageRating)
                    }
                }
            }
        }
    }
}

@Composable
private fun AverageRatingIcon(index: Int, rating: Double) {
    val (iconRes, iconTint) = when {
        rating >= index -> R.drawable.ic_star to SelectedStarColor
        rating > index - 1 -> R.drawable.ic_star_half to SelectedStarColor
        else -> R.drawable.ic_star to UnselectedStarColor
    }

    Icon(
        painter = painterResource(iconRes),
        contentDescription = null,
        tint = iconTint,
        modifier = Modifier.size(16.dp)
    )
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
