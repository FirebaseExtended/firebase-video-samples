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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.data.model.Tag
import com.google.firebase.example.friendlymeals.ui.recipeList.RecipeListViewModel
import com.google.firebase.example.friendlymeals.ui.shared.RatingButton
import com.google.firebase.example.friendlymeals.ui.theme.BorderColor
import com.google.firebase.example.friendlymeals.ui.theme.Charcoal
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import com.google.firebase.example.friendlymeals.ui.theme.LightTeal
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import kotlinx.serialization.Serializable

@Serializable
object FilterRoute

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterScreen(
    viewModel: RecipeListViewModel = hiltViewModel(),
    navigateBack: () -> Unit
) {
    val filterOptions = viewModel.filterOptions.collectAsStateWithLifecycle()
    val tags = viewModel.tags.collectAsStateWithLifecycle()

    FilterScreenContent(
        navigateBack = navigateBack,
        updateRecipeTitle = viewModel::updateRecipeTitle,
        updateFilterByMine = viewModel::updateFilterByMine,
        updateRating = viewModel::updateRating,
        removeTag = viewModel::removeTag,
        addTag = viewModel::addTag,
        updateSortBy = viewModel::updateSortBy,
        resetFilters = viewModel::resetFilters,
        applyFilters = viewModel::applyFilters,
        filterOptions = filterOptions.value,
        tags = tags.value
    )

    LaunchedEffect(true) {
        viewModel.loadPopularTags()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterScreenContent(
    navigateBack: () -> Unit = {},
    updateRecipeTitle: (String) -> Unit = {},
    updateFilterByMine: () -> Unit = {},
    updateRating: (Int) -> Unit = {},
    removeTag: (String) -> Unit = {},
    addTag: (String) -> Unit = {},
    updateSortBy: (SortByFilter) -> Unit = {},
    resetFilters: () -> Unit = {},
    applyFilters: () -> Unit = {},
    filterOptions: FilterOptions,
    tags: List<Tag>
) {
    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        stringResource(id = R.string.filter_title),
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { navigateBack() }) {
                        Icon(
                            painter = painterResource(R.drawable.ic_arrow_back),
                            contentDescription = stringResource(id = R.string.recipe_back_button_content_description)
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
                text = stringResource(id = R.string.filter_recipe_title_label),
                fontWeight = FontWeight.Medium,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            OutlinedTextField(
                value = filterOptions.recipeTitle,
                onValueChange = { updateRecipeTitle(it) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text(stringResource(id = R.string.filter_recipe_title_hint), color = Color.Gray) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = BorderColor,
                    unfocusedBorderColor = BorderColor
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_by_mine_label),
                fontWeight = FontWeight.Medium,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Switch(
                checked = filterOptions.filterByMine,
                onCheckedChange = { updateFilterByMine() },
                colors = SwitchDefaults.colors(
                    checkedThumbColor = Color.White,
                    checkedTrackColor = Teal,
                    uncheckedThumbColor = Charcoal,
                    uncheckedTrackColor = LightTeal,
                    uncheckedBorderColor = Teal
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_rating_label),
                fontWeight = FontWeight.Medium,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                repeat(5) { index ->
                    val rating = index + 1
                    val isSelected = rating == filterOptions.rating
                    val isFilled = rating < filterOptions.rating
                    
                    RatingButton(
                        rating = rating,
                        isSelected = isSelected,
                        isFilled = isFilled,
                        onClick = { updateRating(rating) }
                    )
                }
            }

            if (tags.isNotEmpty()) {
                Spacer(modifier = Modifier.height(24.dp))

                Text(
                    text = stringResource(id = R.string.filter_tags_label),
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    tags.forEach { tag ->
                        val isSelected = filterOptions.selectedTags.contains(tag.name)

                        FilterChip(
                            text = tag.name,
                            isSelected = isSelected,
                            onClick = {
                                if (isSelected) {
                                    removeTag(tag.name)
                                } else {
                                    addTag(tag.name)
                                }
                            }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = stringResource(id = R.string.filter_sort_by_label),
                fontWeight = FontWeight.Medium,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(
                    selected = filterOptions.sortBy == SortByFilter.RATING,
                    onClick = { updateSortBy(SortByFilter.RATING) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = SortByFilter.RATING.title))
                
                Spacer(modifier = Modifier.width(24.dp))
                
                RadioButton(
                    selected = filterOptions.sortBy == SortByFilter.ALPHABETICAL,
                    onClick = { updateSortBy(SortByFilter.ALPHABETICAL) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = SortByFilter.ALPHABETICAL.title))
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(
                    selected = filterOptions.sortBy == SortByFilter.POPULARITY,
                    onClick = { updateSortBy(SortByFilter.POPULARITY) },
                    colors = RadioButtonDefaults.colors(selectedColor = Teal)
                )
                Text(stringResource(id = SortByFilter.POPULARITY.title))

                Spacer(modifier = Modifier.width(24.dp))
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
            filterOptions = FilterOptions(),
            tags = listOf()
        )
    }
}
