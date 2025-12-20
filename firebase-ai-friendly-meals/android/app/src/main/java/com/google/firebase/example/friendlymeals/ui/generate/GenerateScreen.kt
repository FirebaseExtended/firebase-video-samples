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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.shared.CameraComponent
import com.google.firebase.example.friendlymeals.ui.shared.LoadingIndicator
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.Teal
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
        onNotesUpdated = viewModel::onNotesUpdated,
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
    onNotesUpdated: (String) -> Unit = {},
    onImageTaken: (Bitmap?) -> Unit = {},
    onGenerateClick: ((String) -> Unit) -> Unit = {},
    openRecipeScreen: (String) -> Unit = {},
    viewState: GenerateViewState
) {
    Scaffold(
        topBar = {
            Text(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                text = stringResource(id = R.string.generate_new_recipe_title),
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold
            )
        }
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
                onNotesUpdated = onNotesUpdated,
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
    onNotesUpdated: (String) -> Unit,
    onImageTaken: (Bitmap?) -> Unit,
    onGenerateClick: ((String) -> Unit) -> Unit,
    openRecipeScreen: (String) -> Unit,
    viewState: GenerateViewState
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Text(
            text = stringResource(id = R.string.generate_ingredients_label),
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        val ingredientsHint = if (viewState.ingredientsLoading) {
            stringResource(id = R.string.generate_ingredients_loading_hint)
        } else {
            stringResource(id = R.string.generate_ingredients_hint)
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
                unfocusedBorderColor = Color.LightGray
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
            text = stringResource(id = R.string.generate_notes_label),
            fontSize = 16.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        OutlinedTextField(
            value = viewState.notes,
            onValueChange = { onNotesUpdated(it) },
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp),
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color.LightGray,
                unfocusedBorderColor = Color.LightGray
            ),
            placeholder = {
                Text(
                    text = stringResource(id = R.string.generate_notes_hint),
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
            onClick = { onGenerateClick(openRecipeScreen) }
        ) {
            Text(
                text = stringResource(id = R.string.generate_recipe_button_text),
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
fun GenerateScreenPreview() {
    FriendlyMealsTheme {
        GenerateScreenContent(
            viewState = GenerateViewState()
        )
    }
}