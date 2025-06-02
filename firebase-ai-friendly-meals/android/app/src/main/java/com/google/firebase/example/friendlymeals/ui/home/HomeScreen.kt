package com.google.firebase.example.friendlymeals.ui.home

import android.Manifest
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts.RequestPermission
import androidx.activity.result.contract.ActivityResultContracts.TakePicture
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldColors
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.data.model.Recipe
import com.google.firebase.example.friendlymeals.ui.shared.LoadingIndicator
import com.google.firebase.example.friendlymeals.ui.theme.DarkFirebaseYellow
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.MediumFirebaseYellow
import com.halilibo.richtext.commonmark.Markdown
import com.halilibo.richtext.ui.BasicRichText
import kotlinx.serialization.Serializable
import java.io.File

@Serializable
object HomeRoute

@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val viewState = viewModel.viewState.collectAsStateWithLifecycle()

    HomeScreenContent(
        onIngredientsUpdated = viewModel::onIngredientsUpdated,
        onImageTaken = viewModel::onImageTaken,
        onGenerateClick = viewModel::generateRecipe,
        viewState = viewState.value
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreenContent(
    modifier: Modifier = Modifier,
    onIngredientsUpdated: (String) -> Unit,
    onImageTaken: (Bitmap?) -> Unit,
    onGenerateClick: (String, String) -> Unit,
    viewState: HomeViewState
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
            IngredientsBox(
                onIngredientsUpdated = onIngredientsUpdated,
                onImageTaken = onImageTaken,
                onGenerateClick = onGenerateClick,
                viewState = viewState
            )

            Spacer(modifier = Modifier.size(16.dp))

            if (viewState.recipeLoading) {
                Box(
                    modifier = modifier
                        .fillMaxWidth()
                        .padding(horizontal = 8.dp)
                        .clip(RoundedCornerShape(48f))
                        .border(2.dp, DarkFirebaseYellow, RoundedCornerShape(48f))
                        .background(MediumFirebaseYellow)
                        .padding(16.dp)
                ) {
                    LoadingIndicator()
                }
            }

            if (viewState.recipe != null) RecipeBox(recipe = viewState.recipe)
        }
    }
}

@Composable
fun IngredientsBox(
    modifier: Modifier = Modifier,
    onIngredientsUpdated: (String) -> Unit,
    onImageTaken: (Bitmap?) -> Unit,
    onGenerateClick: (String, String) -> Unit,
    viewState: HomeViewState
) {
    val context = LocalContext.current
    var notes by remember { mutableStateOf("") }
    var tempFileUrl by remember { mutableStateOf<Uri?>(null) }

    val cameraLauncher = rememberLauncherForActivityResult(TakePicture()) { imageTaken ->
        if (imageTaken) {
            val imageBitmap = createImageBitmap(context, tempFileUrl)
            onImageTaken(imageBitmap)
        } else {
            tempFileUrl = null
        }
    }

    val permissionLauncher = rememberLauncherForActivityResult(RequestPermission()) { permissionGranted ->
        if (permissionGranted) {
            tempFileUrl = createTempFileUrl(context)
            tempFileUrl?.let { cameraLauncher.launch(it) }
        }
    }

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
            Box {
                TextField(
                    value = viewState.ingredients,
                    onValueChange = onIngredientsUpdated,
                    modifier = Modifier
                        .fillMaxWidth().height(128.dp),
                    shape = RoundedCornerShape(24.dp),
                    colors = getTextFieldColors(),
                    enabled = !viewState.ingredientsLoading,
                    placeholder = { Text(text = stringResource(R.string.ingredients_hint)) }
                )

                if (viewState.ingredients.isBlank()) {
                    Icon(
                        painter = painterResource(R.drawable.ic_camera),
                        contentDescription = "Camera Icon",
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .clickable(
                                interactionSource = remember { MutableInteractionSource() },
                                indication = null,
                                onClick = {
                                    if (!viewState.ingredientsLoading) {
                                        permissionLauncher.launch(Manifest.permission.CAMERA)
                                    }
                                }
                            )
                            .padding(end = 12.dp, top = 12.dp)
                    )
                }

                if (viewState.ingredientsLoading) {
                    Box(
                        modifier = Modifier.fillMaxWidth().height(128.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        LoadingIndicator()
                    }
                }
            }

            Spacer(modifier = Modifier.size(16.dp))

            TextField(
                value = notes,
                onValueChange = { notes = it },
                modifier = Modifier
                    .fillMaxWidth().height(128.dp),
                shape = RoundedCornerShape(24.dp),
                colors = getTextFieldColors(),
                placeholder = { Text(text = stringResource(R.string.notes_hint)) }
            )

            Spacer(modifier = Modifier.size(16.dp))

            val generateButtonEnabled = viewState.ingredients.isNotBlank()
                    && !viewState.recipeLoading
                    && !viewState.ingredientsLoading

            Button(
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = DarkFirebaseYellow,
                    contentColor = Color.White,
                    disabledContainerColor = Color.LightGray,
                    disabledContentColor = Color.Gray
                ),
                enabled = generateButtonEnabled,
                onClick = { onGenerateClick(viewState.ingredients, notes) }
            ) {
                Text(stringResource(R.string.generate_recipe_button), fontSize = 16.sp)
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

            BasicRichText {
                Markdown(recipe.description)
            }
        }
    }
}

private fun createTempFileUrl(context: Context): Uri? {
    val tempFile = File.createTempFile(
        "temp_image_file_",
        ".jpg",
        context.cacheDir
    )

    return FileProvider.getUriForFile(context,
        "com.google.firebase.example.friendlymeals.provider",
        tempFile
    )
}

@Composable
private fun getTextFieldColors(): TextFieldColors {
    return TextFieldDefaults.colors(
        focusedIndicatorColor = Color.Transparent,
        unfocusedIndicatorColor = Color.Transparent,
        disabledIndicatorColor = Color.Transparent
    )
}

private fun createImageBitmap(context: Context, tempFileUrl: Uri?): Bitmap? {
    return tempFileUrl?.let {
        val imageInputStream = context.contentResolver.openInputStream(it)
        val bitmap = BitmapFactory.decodeStream(imageInputStream)
        imageInputStream?.close()
        bitmap
    }
}

@Composable
@Preview(showSystemUi = true)
fun HomeScreenPreview() {
    FriendlyMealsTheme(darkTheme = true) {
        HomeScreenContent(
            onIngredientsUpdated = {},
            onImageTaken = {},
            onGenerateClick = { _, _ -> },
            viewState = HomeViewState()
        )
    }
}