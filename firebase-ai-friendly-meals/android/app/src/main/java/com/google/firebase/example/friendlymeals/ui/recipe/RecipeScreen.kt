package com.google.firebase.example.friendlymeals.ui.recipe

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.shared.RatingButton
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.LightTeal
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import com.halilibo.richtext.commonmark.Markdown
import com.halilibo.richtext.ui.BasicRichText
import kotlinx.serialization.Serializable

@Serializable
data class RecipeRoute(val recipeId: String)

@Composable
fun RecipeScreen(
    viewModel: RecipeViewModel = hiltViewModel(),
    navigateBack: () -> Unit
) {
    val recipeViewState = viewModel.recipeViewState.collectAsStateWithLifecycle()

    RecipeScreenContent(
        navigateBack = navigateBack,
        toggleFavorite = viewModel::toggleFavorite,
        leaveReview = viewModel::leaveReview,
        recipeViewState = recipeViewState.value
    )

    LaunchedEffect(true) {
        viewModel.loadRecipe()
    }
}

@Composable
fun RecipeScreenContent(
    navigateBack: () -> Unit = {},
    toggleFavorite: () -> Unit = {},
    leaveReview: (Int) -> Unit = {},
    recipeViewState: RecipeViewState
) {
    val favoriteIcon = if (recipeViewState.saved) {
        painterResource(R.drawable.ic_favorite_filled)
    } else {
        painterResource(R.drawable.ic_favorite_outline)
    }

    Scaffold { innerPadding ->
        Box(modifier = Modifier.fillMaxSize()) {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(300.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(Color.LightGray)
                        ) {
                            val image = recipeViewState.recipeImage?.asImageBitmap()

                            if (image != null) {
                                Image(
                                    bitmap = image,
                                    contentDescription = stringResource(id = R.string.recipe_image_content_description),
                                    contentScale = ContentScale.Crop,
                                    modifier = Modifier.fillMaxSize()
                                )
                            } else {
                                Text(
                                    text = stringResource(id = R.string.recipe_image_load_error),
                                    color = Color.White,
                                    modifier = Modifier.align(Alignment.Center)
                                )
                            }
                        }

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 16.dp, start = 16.dp, end = 16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            IconButton(
                                onClick = { navigateBack() },
                                modifier = Modifier
                                    .background(Color.White.copy(alpha = 0.8f), CircleShape)
                                    .size(40.dp)
                            ) {
                                Icon(
                                    painter = painterResource(R.drawable.ic_arrow_back),
                                    contentDescription = stringResource(id = R.string.recipe_back_button_content_description),
                                    tint = TextColor
                                )
                            }
                            IconButton(
                                onClick = { toggleFavorite() },
                                modifier = Modifier
                                    .background(Color.White.copy(alpha = 0.8f), CircleShape)
                                    .size(40.dp)
                            ) {
                                Icon(
                                    painter = favoriteIcon,
                                    contentDescription = stringResource(id = R.string.recipe_favorite_button_content_description),
                                    tint = TextColor
                                )
                            }
                        }
                    }
                }

                item {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 24.dp)
                    ) {
                        Spacer(modifier = Modifier.height(24.dp))

                        Text(
                            text = recipeViewState.recipe.title,
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            lineHeight = 34.sp
                        )

                        Spacer(modifier = Modifier.height(24.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            InfoCard(
                                icon = painterResource(R.drawable.ic_timer),
                                label = stringResource(id = R.string.recipe_prep_time_label),
                                value = recipeViewState.recipe.prepTime,
                                modifier = Modifier.weight(1f)
                            )

                            Spacer(modifier = Modifier.width(12.dp))

                            InfoCard(
                                icon = painterResource(R.drawable.ic_cook),
                                label = stringResource(id = R.string.recipe_cook_time_label),
                                value = recipeViewState.recipe.cookTime,
                                modifier = Modifier.weight(1f)
                            )

                            Spacer(modifier = Modifier.width(12.dp))

                            InfoCard(
                                icon = painterResource(R.drawable.ic_serving),
                                label = stringResource(id = R.string.recipe_servings_label),
                                value = recipeViewState.recipe.servings,
                                modifier = Modifier.weight(1f)
                            )
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    text = stringResource(id = R.string.recipe_ingredients_title),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Teal
                                )

                                Spacer(modifier = Modifier.height(12.dp))

                                recipeViewState.recipe.ingredients.forEach {
                                    IngredientRow(it)
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    text = stringResource(id = R.string.recipe_instructions_title),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Teal
                                )
                                Spacer(modifier = Modifier.height(12.dp))

                                BasicRichText {
                                    Markdown(recipeViewState.recipe.instructions)
                                }
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(24.dp))

                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    text = stringResource(id =  R.string.recipe_rating_title),
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = Teal
                                )

                                Spacer(modifier = Modifier.height(12.dp))

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    repeat(5) { index ->
                                        val rating = index + 1
                                        val isSelected = rating == recipeViewState.rating
                                        val isFilled = rating < recipeViewState.rating

                                        RatingButton(
                                            rating = rating,
                                            isSelected = isSelected,
                                            isFilled = isFilled,
                                            onClick = { leaveReview(rating) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun InfoCard(
    icon: Painter,
    label: String,
    value: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .background(LightTeal, RoundedCornerShape(12.dp))
            .padding(vertical = 12.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            painter = icon,
            contentDescription = null,
            tint = Teal,
            modifier = Modifier.size(20.dp)
        )

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = label,
            fontSize = 12.sp,
            color = Color.Gray
        )

        Spacer(modifier = Modifier.height(2.dp))

        Text(
            text = value,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold,
            color = TextColor
        )
    }
}

@Composable
fun IngredientRow(text: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
    ) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .background(LightTeal, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_check),
                contentDescription = null,
                tint = Teal,
                modifier = Modifier.size(14.dp)
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        Text(
            text = text,
            fontSize = 15.sp,
            color = TextColor
        )
    }
}

@Preview
@Composable
fun RecipeScreenPreview() {
    FriendlyMealsTheme {
        RecipeScreenContent(
            recipeViewState = RecipeViewState()
        )
    }
}
