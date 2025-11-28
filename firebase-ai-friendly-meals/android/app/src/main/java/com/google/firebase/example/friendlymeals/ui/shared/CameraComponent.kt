package com.google.firebase.example.friendlymeals.ui.shared

import android.Manifest
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts.RequestPermission
import androidx.activity.result.contract.ActivityResultContracts.TakePicture
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import com.google.firebase.example.friendlymeals.R
import com.google.firebase.example.friendlymeals.ui.theme.Teal
import com.google.firebase.example.friendlymeals.ui.theme.TextColor
import java.io.File

@Composable
fun CameraComponent(
    onImageTaken: (Bitmap?) -> Unit,
    isTopBarIcon: Boolean = true
) {
    val context = LocalContext.current
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

    if (isTopBarIcon) {
        CameraIcon {
            permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    } else {
        CameraButton {
            permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }
}

@Composable
private fun CameraIcon(onClick: () -> Unit) {
    IconButton(onClick = { onClick() }) {
        Icon(
            painter = painterResource(R.drawable.ic_camera),
            contentDescription = "Camera",
            tint = TextColor
        )
    }
}

@Composable
private fun CameraButton(onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .drawBehind {
                val stroke = Stroke(
                    width = 2.dp.toPx(),
                    pathEffect = PathEffect.dashPathEffect(floatArrayOf(20f, 20f), 0f)
                )
                drawRoundRect(
                    color = Color.LightGray,
                    style = stroke,
                    cornerRadius = CornerRadius(16.dp.toPx())
                )
            }
            .clip(RoundedCornerShape(16.dp))
            .clickable { onClick() }
            .background(Color.Transparent),
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_camera),
                contentDescription = "Camera",
                tint = Teal,
                modifier = Modifier.size(24.dp)
            )

            Spacer(modifier = Modifier.size(8.dp))

            Text(
                text = "Take a picture of ingredients",
                color = Teal,
                fontWeight = FontWeight.Medium
            )
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

private fun createImageBitmap(context: Context, tempFileUrl: Uri?): Bitmap? {
    return tempFileUrl?.let {
        val imageInputStream = context.contentResolver.openInputStream(it)
        val bitmap = BitmapFactory.decodeStream(imageInputStream)
        imageInputStream?.close()
        bitmap
    }
}