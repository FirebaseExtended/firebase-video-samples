package com.google.firebase.example.friendlymeals.ui.generate

import android.graphics.Bitmap
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.ui.shared.CameraComponent
import com.google.firebase.example.friendlymeals.ui.shared.LoadingIndicator
import com.google.firebase.example.friendlymeals.ui.theme.BackgroundColor
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import kotlinx.serialization.Serializable

@Serializable
object GenerateRoute

@Composable
fun GenerateScreen(
    viewModel: GenerateViewModel = hiltViewModel(),
    openRecipeScreen: (String) -> Unit
) {
    val viewState = viewModel.viewState.collectAsStateWithLifecycle()

    GenerateScreenContent(
        onIngredientsUpdated = viewModel::onIngredientsUpdated,
        onImageTaken = viewModel::onImageTaken,
        onGenerateClick = viewModel::generateRecipe,
        openRecipeScreen = openRecipeScreen,
        viewState = viewState.value
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GenerateScreenContent(
    onIngredientsUpdated: (String) -> Unit = {},
    onImageTaken: (Bitmap?) -> Unit = {},
    onGenerateClick: (String, String, (String) -> Unit) -> Unit = { _, _, _ -> },
    openRecipeScreen: (String) -> Unit = {},
    viewState: GenerateViewState
) {
    Scaffold(
        topBar = {
            Text(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                text = "New recipe",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = TextColor
            )
        },
        containerColor = BackgroundColor
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 24.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Spacer(modifier = Modifier.size(8.dp))

            IngredientsSection(
                onIngredientsUpdated = onIngredientsUpdated,
                onImageTaken = onImageTaken,
                onGenerateClick = onGenerateClick,
                openRecipeScreen = openRecipeScreen,
                viewState = viewState
            )
        }
    }
}

@Composable
fun IngredientsSection(
    modifier: Modifier = Modifier,
    onIngredientsUpdated: (String) -> Unit,
    onImageTaken: (Bitmap?) -> Unit,
    onGenerateClick: (String, String, (String) -> Unit) -> Unit,
    openRecipeScreen: (String) -> Unit,
    viewState: GenerateViewState
) {
    var notes by remember { mutableStateOf("") }

    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = "List your ingredients",
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium,
            color = TextColor,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        val ingredientsHint = if (viewState.ingredientsLoading) {
            "Loading..."
        } else {
            "e.g., pasta, tomato, garlic, bacon, eggs"
        }

        OutlinedTextField(
            value = viewState.ingredients,
            onValueChange = onIngredientsUpdated,
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp),
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.LightGray,
                unfocusedBorderColor = Color.LightGray,
                focusedContainerColor = Color.White,
                unfocusedContainerColor = Color.White
            ),
            enabled = !viewState.ingredientsLoading,
            placeholder = {
                Text(
                    text = ingredientsHint,
                    color = Color.Gray
                )
            }
        )

        Spacer(modifier = Modifier.size(24.dp))

        CameraComponent(onImageTaken, isTopBarIcon = false)

        Spacer(modifier = Modifier.size(24.dp))

        Text(
            text = "Any special notes or cuisines?",
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium,
            color = TextColor,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        OutlinedTextField(
            value = notes,
            onValueChange = { notes = it },
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp),
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.LightGray,
                unfocusedBorderColor = Color.LightGray,
                focusedContainerColor = Color.White,
                unfocusedContainerColor = Color.White
            ),
            placeholder = {
                Text(
                    text = "e.g., vegetarian, gluten-free, Italian",
                    color = Color.Gray
                )
            }
        )

        Spacer(modifier = Modifier.size(48.dp))

        val generateButtonEnabled = viewState.ingredients.isNotBlank()
                && !viewState.recipeLoading
                && !viewState.ingredientsLoading

        Button(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(16.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Teal,
                contentColor = Color.White,
                disabledContainerColor = Color.LightGray,
                disabledContentColor = Color.Gray
            ),
            enabled = generateButtonEnabled,
            onClick = { onGenerateClick(viewState.ingredients, notes, openRecipeScreen) }
        ) {
            Text(
                text = "Generate Recipe",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.size(24.dp))

        if (viewState.recipeLoading || viewState.ingredientsLoading) {
            Spacer(modifier = Modifier.size(24.dp))

            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                LoadingIndicator()
            }
        }
    }
}

@Composable
@Preview
fun HomeScreenPreview() {
    FriendlyMealsTheme {
        GenerateScreenContent(
            viewState = GenerateViewState()
        )
    }
}