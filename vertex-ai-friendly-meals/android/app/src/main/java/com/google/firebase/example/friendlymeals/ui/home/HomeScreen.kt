package com.google.firebase.example.friendlymeals.ui.home

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonColors
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberTopAppBarState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.ui.theme.DarkFirebaseYellow
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.LightFirebaseYellow
import com.google.firebase.example.friendlymeals.ui.theme.MediumFirebaseYellow
import kotlinx.serialization.Serializable

@Serializable
object HomeRoute

@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val recipe = viewModel.recipe.collectAsStateWithLifecycle()

    HomeScreenContent(
        onGenerateClick = viewModel::generateRecipe,
        recipe = recipe.value
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreenContent(
    modifier: Modifier = Modifier,
    onGenerateClick: (String, String) -> Unit,
    recipe: Recipe?
) {
    val scrollBehavior = TopAppBarDefaults.pinnedScrollBehavior(rememberTopAppBarState())

    Scaffold(
        modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection)
    ) { innerPadding ->
        Column(
            modifier = modifier
            .fillMaxWidth()
            .padding(innerPadding)
            .verticalScroll(rememberScrollState())
        ) {
            IngredientsBox(onGenerateClick = onGenerateClick)

            Spacer(modifier = Modifier.size(16.dp))

            if (recipe != null) RecipeBox(recipe = recipe)
        }
    }
}

@Composable
fun IngredientsBox(
    modifier: Modifier = Modifier,
    onGenerateClick: (String, String) -> Unit,
) {
    var ingredients by remember { mutableStateOf("") }
    var cuisines by remember { mutableStateOf("") }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp)
            .clip(RoundedCornerShape(48f))
            .border(2.dp, DarkFirebaseYellow, RoundedCornerShape(48f))
            .background(MediumFirebaseYellow)
            .padding(16.dp)
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            TextField(
                value = ingredients,
                onValueChange = { ingredients = it },
                modifier = Modifier
                    .fillMaxWidth().height(128.dp),
                shape = RoundedCornerShape(24.dp),
                colors = TextFieldDefaults.colors(
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    disabledIndicatorColor = Color.Transparent,
                    focusedContainerColor = LightFirebaseYellow,
                    unfocusedContainerColor = LightFirebaseYellow
                ),
                placeholder = {
                    Text(text = "Enter your list of ingredients")
                }
            )

            Spacer(modifier = Modifier.size(16.dp))

            TextField(
                value = cuisines,
                onValueChange = { cuisines = it },
                modifier = Modifier
                    .fillMaxWidth().height(72.dp),
                shape = RoundedCornerShape(24.dp),
                colors = TextFieldDefaults.colors(
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    disabledIndicatorColor = Color.Transparent,
                    focusedContainerColor = LightFirebaseYellow,
                    unfocusedContainerColor = LightFirebaseYellow
                ),
                placeholder = {
                    Text(text = "Enter preferred cuisines")
                }
            )

            Spacer(modifier = Modifier.size(16.dp))

            Button(
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonColors(
                    containerColor = DarkFirebaseYellow,
                    contentColor = Color.White,
                    disabledContainerColor = LightFirebaseYellow,
                    disabledContentColor = Color.Gray
                ),
                onClick = { onGenerateClick(ingredients, cuisines) }
            ) {
                Text("Generate recipe", fontSize = 16.sp)
            }
        }
    }
}

@Composable
fun RecipeBox(
    modifier: Modifier = Modifier,
    recipe: Recipe
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp)
            .clip(RoundedCornerShape(48f))
            .border(2.dp, DarkFirebaseYellow, RoundedCornerShape(48f))
            .background(MediumFirebaseYellow)
            .padding(16.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            val image = recipe.image?.asImageBitmap()

            if (image != null) {
                Image(bitmap = image, "Recipe image")
            }

            Spacer(modifier = Modifier.size(16.dp))

            Text(text = recipe.description)
        }
    }
}

@Composable
@Preview(showSystemUi = true)
fun HomeScreenPreview() {
    FriendlyMealsTheme(darkTheme = true) {
        HomeScreenContent(
            onGenerateClick = { _, _ -> },
            recipe = Recipe()
        )
    }
}