package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import com.google.firebase.storage.StorageReference
import kotlinx.coroutines.tasks.await
import java.io.ByteArrayOutputStream
import javax.inject.Inject
import androidx.core.graphics.scale
import java.util.UUID

class StorageRemoteDataSource @Inject constructor(
    private val storageRef: StorageReference
) {
    suspend fun addImage(image: Bitmap): String {
        val scaledBitmap = scaleBitmap(image)
        val stream = ByteArrayOutputStream()
        scaledBitmap.compress(Bitmap.CompressFormat.WEBP, 70, stream)
        val data = stream.toByteArray()

        val randomId = UUID.randomUUID().toString()
        val imagesRef = storageRef.child("images/$randomId.webp")
        imagesRef.putBytes(data).await()

        return imagesRef.downloadUrl.await().toString()
    }

    private fun scaleBitmap(source: Bitmap): Bitmap {
        val lastWidth = source.width
        val lastHeight = source.height
        val outWidth: Int
        val outHeight: Int

        if (lastWidth > lastHeight) {
            outWidth = MAX_IMAGE_LENGTH
            outHeight = (lastHeight.toFloat() / lastWidth * MAX_IMAGE_LENGTH).toInt()
        } else {
            outHeight = MAX_IMAGE_LENGTH
            outWidth = (lastWidth.toFloat() / lastHeight * MAX_IMAGE_LENGTH).toInt()
        }
        return source.scale(outWidth, outHeight)
    }

    companion object {
        private const val MAX_IMAGE_LENGTH = 800
    }
}