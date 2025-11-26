package com.google.firebase.example.friendlymeals.ui.recipe

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
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.theme.FriendlyMealsTheme
import kotlinx.serialization.Serializable

@Serializable
object RecipeRoute

// Define colors locally to match the design
private val TealColor = Color(0xFF1EB980)
private val BackgroundColor = Color(0xFFF8F9FA)
private val TextColor = Color(0xFF1F2937)
private val CardBackgroundColor = Color.White
private val LightGrayColor = Color(0xFFF3F4F6)

@Composable
fun RecipeScreen() {
    Scaffold(
        containerColor = BackgroundColor
    ) { innerPadding ->
        Box(modifier = Modifier.fillMaxSize()) {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                item {
                    // Header Image Section
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(300.dp)
                    ) {
                        // Placeholder for the food image
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(Color.DarkGray)
                        ) {
                            // In a real app, use Image composable here
                             Text(
                                 "Food Image Placeholder",
                                 color = Color.White,
                                 modifier = Modifier.align(Alignment.Center)
                             )
                        }

                        // Top Buttons
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 16.dp, start = 16.dp, end = 16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            IconButton(
                                onClick = { /* TODO */ },
                                modifier = Modifier
                                    .background(Color.White.copy(alpha = 0.8f), CircleShape)
                                    .size(40.dp)
                            ) {
                                Icon(
                                    painter = painterResource(R.drawable.ic_arrow_back),
                                    contentDescription = "Back",
                                    tint = TextColor
                                )
                            }
                            IconButton(
                                onClick = { /* TODO */ },
                                modifier = Modifier
                                    .background(Color.White.copy(alpha = 0.8f), CircleShape)
                                    .size(40.dp)
                            ) {
                                Icon(
                                    painter = painterResource(R.drawable.ic_favorite_outline),
                                    contentDescription = "Share",
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
                        Spacer(modifier = Modifier.height(24.dp)) // Space for FAB overlap

                        Text(
                            text = "Creamy Tomato and Basil Pasta",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = TextColor,
                            lineHeight = 34.sp
                        )

                        Spacer(modifier = Modifier.height(24.dp))

                        // Info Cards
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            InfoCard(
                                icon = painterResource(R.drawable.ic_timer),
                                label = "Prep Time",
                                value = "10 mins",
                                modifier = Modifier.weight(1f)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            InfoCard(
                                icon = painterResource(R.drawable.ic_cook),
                                label = "Cook Time",
                                value = "20 mins",
                                modifier = Modifier.weight(1f)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            InfoCard(
                                icon = painterResource(R.drawable.ic_serving),
                                label = "Servings",
                                value = "2",
                                modifier = Modifier.weight(1f)
                            )
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        // Ingredients Section
                        Card(
                            colors = CardDefaults.cardColors(containerColor = CardBackgroundColor),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    text = "Ingredients",
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = TealColor
                                )
                                Spacer(modifier = Modifier.height(12.dp))
                                IngredientRow("200g Pasta")
                                IngredientRow("4 ripe tomatoes")
                                IngredientRow("2 cloves garlic")
                                IngredientRow("1/2 cup heavy cream")
                                IngredientRow("Fresh basil leaves")
                            }
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        // Instructions Section
                        Card(
                            colors = CardDefaults.cardColors(containerColor = CardBackgroundColor),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    text = "Instructions",
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = TealColor
                                )
                                Spacer(modifier = Modifier.height(12.dp))
                                InstructionStep(
                                    "1. ",
                                    "Boil",
                                    " water in a large pot. Add a generous pinch of salt and cook the pasta according to package directions until al dente."
                                )
                                InstructionStep(
                                    "2. ",
                                    "While the pasta cooks, ",
                                    "sauté",
                                    " the minced garlic in olive oil over medium heat in a large skillet until fragrant."
                                )
                                InstructionStep(
                                    "3. ",
                                    "Add",
                                    " the diced tomatoes to the skillet. Cook for 5–7 minutes, until they start to break down."
                                )
                                InstructionStep(
                                    "4. ",
                                    "Reduce",
                                    " heat to low and stir in the heavy cream. Season with salt and pepper to taste. Let it simmer gently."
                                )
                                InstructionStep(
                                    "5. ",
                                    "Drain",
                                    " the pasta and add it to the skillet with the sauce. Toss to combine. Stir in a handful of fresh, chopped basil leaves. Serve immediately."
                                )
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(24.dp))
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
            .background(LightGrayColor, RoundedCornerShape(12.dp))
            .padding(vertical = 12.dp, horizontal = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            painter = icon,
            contentDescription = null,
            tint = TealColor,
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
        Checkbox(
            checked = false,
            onCheckedChange = { },
            colors = CheckboxDefaults.colors(
                uncheckedColor = Color.LightGray,
                checkedColor = TealColor
            )
        )
        Text(
            text = text,
            fontSize = 15.sp,
            color = TextColor
        )
    }
}

@Composable
fun InstructionStep(number: String, boldText: String? = null, text: String, boldText2: String? = null) {
     Text(
        text = buildAnnotatedString {
            append(number)
            if (boldText != null) {
                withStyle(style = SpanStyle(fontWeight = FontWeight.Bold)) {
                    append(boldText)
                }
            }
            append(text)
             if (boldText2 != null) {
                withStyle(style = SpanStyle(fontWeight = FontWeight.Bold)) {
                    append(boldText2)
                }
            }
        },
        fontSize = 15.sp,
        color = TextColor,
        lineHeight = 22.sp,
        modifier = Modifier.padding(bottom = 12.dp)
    )
}

// Overload for the specific structure of the instructions in the prompt
@Composable
fun InstructionStep(prefix: String, boldPart: String, suffix: String) {
    Text(
        text = buildAnnotatedString {
            append(prefix)
            withStyle(style = SpanStyle(fontWeight = FontWeight.Bold)) {
                append(boldPart)
            }
            append(suffix)
        },
        fontSize = 15.sp,
        color = TextColor,
        lineHeight = 22.sp,
        modifier = Modifier.padding(bottom = 12.dp)
    )
}

@Composable
fun InstructionStep(prefix: String, part1: String, boldPart: String, suffix: String) {
    Text(
        text = buildAnnotatedString {
            append(prefix)
            append(part1)
            withStyle(style = SpanStyle(fontWeight = FontWeight.Bold)) {
                append(boldPart)
            }
            append(suffix)
        },
        fontSize = 15.sp,
        color = TextColor,
        lineHeight = 22.sp,
        modifier = Modifier.padding(bottom = 12.dp)
    )
}


@Preview
@Composable
fun RecipeScreenPreview() {
    FriendlyMealsTheme {
        RecipeScreen()
    }
}
