package com.google.firebase.example.friendlymeals.ui.recipeList

import androidx.compose.foundation.background
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import kotlinx.serialization.Serializable

@Serializable
object RecipeListRoute

// Define colors locally to match the design
private val TealColor = Color(0xFF1EB980)
private val BackgroundColor = Color(0xFFF8F9FA)
private val TextColor = Color(0xFF1F2937)
private val StarColor = Color(0xFFFFC107)
private val UnselectedStarColor = Color(0xFFE5E7EB)

data class RecipeUiModel(
    val title: String,
    val rating: Int,
    val imageColor: Color // Placeholder for image
)

@Composable
fun RecipeListScreen() {
    val recipes = listOf(
        RecipeUiModel("Creamy Tomato and Basil Pasta", 4, Color(0xFFE57373)),
        RecipeUiModel("Grilled Chicken Salad", 5, Color(0xFF81C784)),
        RecipeUiModel("Avocado Toast with Egg", 4, Color(0xFFFFF176)),
        RecipeUiModel("Berry Smoothie Bowl", 5, Color(0xFFBA68C8))
    )

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
                    text = "My Recipes",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextColor
                )
                IconButton(onClick = { /* TODO */ }) {
                    Icon(
                        painter = painterResource(R.drawable.ic_filter),
                        contentDescription = "Filter",
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
                RecipeCard(recipe)
            }
        }
    }
}

@Composable
fun RecipeCard(recipe: RecipeUiModel) {
    Card(
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Image Placeholder
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(RoundedCornerShape(16.dp))
                    .background(recipe.imageColor)
            )

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
                            contentDescription = null,
                            tint = if (index < recipe.rating) StarColor else UnselectedStarColor,
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
        RecipeListScreen()
    }
}
