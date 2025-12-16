package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.firebase.storage.StorageReference
import kotlinx.coroutines.tasks.await
import java.io.ByteArrayOutputStream
import javax.inject.Inject

class StorageRemoteDataSource @Inject constructor(
    private val storageRef: StorageReference
) {
    fun addImage(image: Bitmap, recipeId: String) {
        val imagesRef = storageRef.child("images/$recipeId.jpg")
        val stream = ByteArrayOutputStream()
        image.compress(Bitmap.CompressFormat.JPEG, 100, stream)
        val data = stream.toByteArray()

        imagesRef.putBytes(data).addOnCompleteListener {
            stream.close()
        }
    }

    suspend fun getImage(recipeId: String): Bitmap? {
        val imagesRef = storageRef.child("images/$recipeId.jpg")
        val bytes = imagesRef.getBytes(MAX_DOWNLOAD_SIZE_BYTES).await()
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    }

    companion object {
        private const val MAX_DOWNLOAD_SIZE_BYTES: Long = 1024 * 1024 * 5
    }
}