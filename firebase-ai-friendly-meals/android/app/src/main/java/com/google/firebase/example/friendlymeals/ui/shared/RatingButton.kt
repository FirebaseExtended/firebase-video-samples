package com.google.firebase.example.friendlymeals.ui.shared

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.theme.BorderColor
import com.google.firebase.example.friendlymeals.ui.theme.SelectedStarColor
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.UnselectedStarColor

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
