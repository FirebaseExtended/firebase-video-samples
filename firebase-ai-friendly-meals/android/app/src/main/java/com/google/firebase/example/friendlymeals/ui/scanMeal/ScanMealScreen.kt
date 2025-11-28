package com.google.firebase.example.friendlymeals.ui.scanMeal

import android.graphics.Bitmap
import androidx.compose.foundation.Image
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.shared.CameraComponent
import com.google.firebase.example.friendlymeals.ui.theme.BackgroundColor
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.LightTeal
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import kotlinx.serialization.Serializable

@Serializable
object ScanMealRoute

@Composable
fun ScanMealScreen(
    viewModel: ScanMealViewModel = hiltViewModel()
) {
    val viewState = viewModel.viewState.collectAsStateWithLifecycle()

    ScanMealScreenContent(
        onImageTaken = viewModel::onImageTaken,
        viewState = viewState.value
    )
}

@Composable
fun ScanMealScreenContent(
    onImageTaken: (Bitmap?) -> Unit = {},
    viewState: ScanMealViewState
) {
    val image = viewState.image?.asImageBitmap()

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
                    text = "Scan Meal",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextColor
                )

                CameraComponent(onImageTaken)
            }
        },
        containerColor = BackgroundColor
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 24.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(300.dp)
                        .clip(RoundedCornerShape(24.dp))
                        .background(Color.LightGray)
                ) {
                    if (image != null) {
                        Image(bitmap = image, "Recipe image")
                    } else {
                        Text(
                            text = "Could not load image",
                            color = Color.White,
                            modifier = Modifier.align(Alignment.Center)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
            }

            item {
                Text(
                    text = "Nutritional Facts",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextColor,
                    modifier = Modifier.padding(bottom = 16.dp)
                )

                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        NutrientCard(
                            modifier = Modifier.weight(1f),
                            label = "Protein",
                            value = viewState.protein
                        )

                        NutrientCard(
                            modifier = Modifier.weight(1f),
                            label = "Fat",
                            value = viewState.fat
                        )
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        NutrientCard(
                            modifier = Modifier.weight(1f),
                            label = "Carbs",
                            value = viewState.carbs
                        )

                        NutrientCard(
                            modifier = Modifier.weight(1f),
                            label = "Sugar",
                            value = viewState.sugar
                        )
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
            }

            if (viewState.ingredients.isNotEmpty()) {
                item {
                    Text(
                        text = "Identified Ingredients",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = TextColor,
                        modifier = Modifier.padding(bottom = 16.dp)
                    )
                }

                items(viewState.ingredients) { ingredient ->
                    IngredientItem(ingredient)
                }
            }
        }
    }
}

@Composable
fun NutrientCard(modifier: Modifier, label: String, value: String) {
    Column(
        modifier = modifier
            .background(LightTeal, RoundedCornerShape(16.dp))
            .padding(vertical = 16.dp, horizontal = 8.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = label,
            color = Teal,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium
        )

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = value,
            color = TextColor,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun IngredientItem(name: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
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
            text = name,
            fontSize = 16.sp,
            color = Color.Gray,
            fontWeight = FontWeight.Normal
        )
    }
}

@Preview
@Composable
fun ScanMealScreenPreview() {
    FriendlyMealsTheme {
        ScanMealScreenContent(
            viewState = ScanMealViewState()
        )
    }
}
