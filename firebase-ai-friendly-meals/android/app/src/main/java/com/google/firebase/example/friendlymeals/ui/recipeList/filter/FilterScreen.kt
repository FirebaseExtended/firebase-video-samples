package com.google.firebase.example.friendlymeals.ui.recipeList.filter

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
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
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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

// Define colors locally to match the design
private val TealColor = Color(0xFF009688) // Adjusted to match image closer
private val LightTealBackground = Color(0xFFE0F2F1) // For selected chips
private val BackgroundColor = Color.White
private val TextColor = Color(0xFF1F2937)
private val StarColor = Color(0xFFFFC107)
private val UnselectedStarColor = Color(0xFF9CA3AF)
private val BorderColor = Color(0xFFE5E7EB)

@Serializable
object FilterRoute

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun FilterScreen() {
    var recipeName by remember { mutableStateOf("") }
    var selectedRating by remember { mutableStateOf(4) }
    val selectedTags = remember { mutableStateOf(setOf("Quick & Easy", "High Protein")) }
    var sortBy by remember { mutableStateOf("Rating") }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        "Filter Recipes",
                        fontWeight = FontWeight.Bold,
                        fontSize = 20.sp,
                        color = TextColor
                    )
                },
                navigationIcon = {
                    IconButton(onClick = { /* TODO */ }) {
                        Icon(
                            painter = painterResource(R.drawable.ic_arrow_back),
                            contentDescription = "Back",
                            tint = TextColor
                        )
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                    containerColor = BackgroundColor
                )
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
            Spacer(modifier = Modifier.height(16.dp))

            // Recipe Name Input
            Text(
                text = "Recipe Name",
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            OutlinedTextField(
                value = recipeName,
                onValueChange = { recipeName = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("e.g. Arrabbiata sauce", color = Color.Gray) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = BorderColor,
                    unfocusedBorderColor = BorderColor,
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            // User Name Input
            Text(
                text = "Username",
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            OutlinedTextField(
                value = recipeName,
                onValueChange = { recipeName = it },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("e.g. John Doe", color = Color.Gray) },
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = BorderColor,
                    unfocusedBorderColor = BorderColor,
                    focusedContainerColor = Color.White,
                    unfocusedContainerColor = Color.White
                )
            )

            Spacer(modifier = Modifier.height(24.dp))

            // Rating Filter
            Text(
                text = "Rating",
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                repeat(5) { index ->
                    val rating = index + 1
                    val isSelected = rating == selectedRating
                    val isFilled = rating <= selectedRating // Logic for stars before selected? 
                    // Looking at image: 
                    // Stars 1, 2, 3 are yellow (filled) but white bg.
                    // Star 4 is white (filled) with teal bg.
                    // Star 5 is grey (unfilled) with white bg.
                    // This implies selecting "4" highlights it specifically, 
                    // or maybe it's just a visual state for "4 Stars".
                    // Let's implement: Click to select a specific rating.
                    
                    RatingButton(
                        rating = rating,
                        isSelected = isSelected,
                        isFilled = rating < selectedRating, // Stars before selected are yellow
                        onClick = { selectedRating = rating }
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Tags Filter
            Text(
                text = "Tags",
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val tags = listOf("Quick & Easy", "Vegan", "Gluten-Free", "High Protein", "Low Carb", "Dessert")
                tags.forEach { tag ->
                    val isSelected = selectedTags.value.contains(tag)
                    FilterChip(
                        text = tag,
                        isSelected = isSelected,
                        onClick = {
                            if (isSelected) {
                                selectedTags.value -= tag
                            } else {
                                selectedTags.value += tag
                            }
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Sort By
            Text(
                text = "Sort By",
                fontWeight = FontWeight.Medium,
                color = TextColor,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(
                    selected = sortBy == "Rating",
                    onClick = { sortBy = "Rating" },
                    colors = RadioButtonDefaults.colors(selectedColor = TealColor)
                )
                Text("Rating", color = TextColor)
                
                Spacer(modifier = Modifier.width(24.dp))
                
                RadioButton(
                    selected = sortBy == "Alphabetical",
                    onClick = { sortBy = "Alphabetical" },
                    colors = RadioButtonDefaults.colors(selectedColor = TealColor)
                )
                Text("Alphabetical", color = TextColor)
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(
                    selected = sortBy == "Popularity",
                    onClick = { sortBy = "Popularity" },
                    colors = RadioButtonDefaults.colors(selectedColor = TealColor)
                )
                Text("Popularity", color = TextColor)

                Spacer(modifier = Modifier.width(24.dp))

                RadioButton(
                    selected = sortBy == "Date added",
                    onClick = { sortBy = "Date added" },
                    colors = RadioButtonDefaults.colors(selectedColor = TealColor)
                )
                Text("Date added", color = TextColor)
            }

            Spacer(modifier = Modifier.weight(1f))
            Spacer(modifier = Modifier.height(24.dp))

            // Bottom Buttons
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                OutlinedButton(
                    onClick = { 
                        // Reset logic
                        recipeName = ""
                        selectedRating = 0
                        selectedTags.value = emptySet()
                        sortBy = "Rating"
                    },
                    modifier = Modifier
                        .weight(1f)
                        .height(56.dp),
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(1.dp, TealColor),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = TealColor)
                ) {
                    Text("Reset", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }

                Button(
                    onClick = { /* Apply logic */ },
                    modifier = Modifier
                        .weight(1f)
                        .height(56.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = TealColor,
                        contentColor = Color.White
                    )
                ) {
                    Text("Apply Filters", fontWeight = FontWeight.Bold, fontSize = 16.sp)
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
            .background(if (isSelected) TealColor else Color.White)
            .border(
                width = 1.dp,
                color = if (isSelected) TealColor else BorderColor,
                shape = CircleShape
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_star),
            contentDescription = "$rating Stars",
            tint = when {
                isSelected -> Color.White
                isFilled -> StarColor
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
            .background(if (isSelected) LightTealBackground else Color.White)
            .border(
                width = 1.dp,
                color = if (isSelected) LightTealBackground else BorderColor,
                shape = RoundedCornerShape(24.dp)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Text(
            text = text,
            color = if (isSelected) TealColor else TextColor,
            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
        )
    }
}

@Preview
@Composable
fun FilterScreenPreview() {
    FriendlyMealsTheme {
        FilterScreen()
    }
}
