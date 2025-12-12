package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.firebase.storage.StorageReference
import java.io.ByteArrayOutputStream
import javax.inject.Inject

class StorageRemoteDataSource @Inject constructor(
    private val storageRef: StorageReference
) {
    fun storeImage(image: Bitmap, recipeId: String) {
        val imagesRef = storageRef.child("images/$recipeId.jpg")
        val stream = ByteArrayOutputStream()
        image.compress(Bitmap.CompressFormat.JPEG, 100, stream)
        val data = stream.toByteArray()

        imagesRef.putBytes(data).addOnCompleteListener {
            stream.close()
        }
    }

    fun retrieveImage(recipeId: String): Bitmap? {
        val imagesRef = storageRef.child("images/$recipeId.jpg")
        var bitmap: Bitmap? = null

        imagesRef.getBytes(MAX_DOWNLOAD_SIZE_BYTES).addOnSuccessListener { bytes ->
            bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        }

        return bitmap
    }

    companion object {
        private const val MAX_DOWNLOAD_SIZE_BYTES: Long = 1024 * 1024 * 5
    }
}