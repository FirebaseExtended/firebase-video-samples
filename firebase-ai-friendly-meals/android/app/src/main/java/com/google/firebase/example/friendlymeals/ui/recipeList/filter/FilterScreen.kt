package com.google.firebase.example.friendlymeals.ui.recipeList.filter

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringArrayResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListViewModel
import com.google.firebase.example.friendlymeals.ui.theme.BorderColor
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.LightTeal
import com.google.firebase.example.friendlymeals.ui.theme.SelectedStarColor
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import com.google.firebase.example.friendlymeals.ui.theme.UnselectedStarColor
import kotlinx.serialization.Serializable

@Serializable
object FilterRoute

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterScreen(
    viewModel: RecipeListViewModel = hiltViewModel(),
    navigateBack: () -> Unit
) {
    val filterState = viewModel.filterState.collectAsStateWithLifecycle()

    FilterScreenContent(
        navigateBack = navigateBack,
        updateRecipeName = viewModel::updateRecipeName,
        updateUsername = viewModel::updateUsername,
        updateRating = viewModel::updateRating,
        removeTag = viewModel::removeTag,
        addTag = viewModel::addTag,
        updateSortBy = viewModel::updateSortBy,
        resetFilters = viewModel::resetFilters,
        applyFilters = viewModel::applyFilters,
        viewState = filterState.value
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterScreenContent(
    navigateBack: () -> Unit = {},
    updateRecipeName: (String) -> Unit = {},
    updateUsername: (String) -> Unit = {},
    updateRating: (Int) -> Unit = {},
    removeTag: (String) -> Unit = {},
    addTag: (String) -> Unit = {},
    updateSortBy: (String) -> Unit = {},
    resetFilters: () -> Unit = {},
    applyFilters: () -> Unit = {},
    viewState: FilterViewState
) {
    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        stringResource(id = R.string.filter_title),
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        color = TextColor
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navigateBack() }) {
                        Icon(
                            painter = painterResource(R.drawable.ic_arrow_back),
                            contentDescription = stringResource(id = R.string.recipe_back_button_content_description),
                            tint = TextColor
                        )
                    }
                }
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
            Spacer(modifier = Modifier.height(16.dp))

            Text(
                text = stringResource(id = R.string.filter_recipe_name_label),
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            OutlinedTextField(
                value = viewState.recipeName,
                onValueChange = { updateRecipeName(it) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(stringResource(id = R.string.filter_recipe_name_hint), color = Color.Gray) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = BorderColor,
                    unfocusedBorderColor = BorderColor,
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_username_label),
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            OutlinedTextField(
                value = viewState.username,
                onValueChange = { updateUsername(it) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(stringResource(id = R.string.filter_username_hint), color = Color.Gray) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = BorderColor,
                    unfocusedBorderColor = BorderColor,
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_rating_label),
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                repeat(5) { index ->
                    val rating = index + 1
                    val isSelected = rating == viewState.rating
                    val isFilled = rating < viewState.rating
                    
                    RatingButton(
                        rating = rating,
                        isSelected = isSelected,
                        isFilled = isFilled,
                        onClick = { updateRating(rating) }
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_tags_label),
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val tags = stringArrayResource(id = R.array.filter_tags)
                //TODO: use ENUM here in the future

                tags.forEach { tag ->
                    val isSelected = viewState.tags.contains(tag)

                    FilterChip(
                        text = tag,
                        isSelected = isSelected,
                        onClick = {
                            if (isSelected) {
                                removeTag(tag)
                            } else {
                                addTag(tag)
                            }
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_sort_by_label),
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            //TODO: use ENUM for sortBy in the future
            //TODO: fix changing the selected radio button

            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(
                    selected = viewState.sortBy == stringResource(id = R.string.filter_sort_by_rating),
                    onClick = { updateSortBy(viewState.sortBy) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = R.string.filter_sort_by_rating), color = TextColor)
                
                Spacer(modifier = Modifier.width(24.dp))
                
                RadioButton(
                    selected = viewState.sortBy == stringResource(id = R.string.filter_sort_by_alphabetical),
                    onClick = { updateSortBy(viewState.sortBy) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = R.string.filter_sort_by_alphabetical), color = TextColor)
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(
                    selected = viewState.sortBy == stringResource(id = R.string.filter_sort_by_popularity),
                    onClick = { updateSortBy(viewState.sortBy) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = R.string.filter_sort_by_popularity), color = TextColor)

                Spacer(modifier = Modifier.width(24.dp))

                RadioButton(
                    selected = viewState.sortBy == stringResource(id = R.string.filter_sort_by_date_added),
                    onClick = { updateSortBy(viewState.sortBy) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = R.string.filter_sort_by_date_added), color = TextColor)
            }

            Spacer(modifier = Modifier.weight(1f))
            Spacer(modifier = Modifier.height(24.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                OutlinedButton(
                    onClick = { resetFilters() },
                    modifier = Modifier
                        .weight(1f)
                        .height(56.dp),
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(1.dp, Teal),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Teal)
                ) {
                    Text(stringResource(id = R.string.filter_reset_button), fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }

                Button(
                    onClick = {
                        applyFilters()
                        navigateBack()
                    },
                    modifier = Modifier
                        .weight(1f)
                        .height(56.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Teal,
                        contentColor = Color.White
                    )
                ) {
                    Text(stringResource(id = R.string.filter_apply_button), fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
fun RatingButton(
    rating: Int,
    isSelected: Boolean,
    isFilled: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .size(48.dp)
            .clip(CircleShape)
            .background(if (isSelected) Teal else Color.White)
            .border(
                width = 1.dp,
                color = if (isSelected) Teal else BorderColor,
                shape = CircleShape
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_star),
            contentDescription = stringResource(id = R.string.filter_rating_content_description, rating),
            tint = when {
                isSelected -> Color.White
                isFilled -> SelectedStarColor
                else -> UnselectedStarColor
            },
            modifier = Modifier.size(24.dp)
        )
    }
}

@Composable
fun FilterChip(
    text: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(24.dp))
            .background(if (isSelected) LightTeal else Color.White)
            .border(
                width = 1.dp,
                color = if (isSelected) LightTeal else BorderColor,
                shape = RoundedCornerShape(24.dp)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Text(
            text = text,
            color = if (isSelected) Teal else TextColor,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
        )
    }
}

@Preview
@Composable
fun FilterScreenPreview() {
    FriendlyMealsTheme {
        FilterScreenContent(
            viewState = FilterViewState()
        )
    }
}
