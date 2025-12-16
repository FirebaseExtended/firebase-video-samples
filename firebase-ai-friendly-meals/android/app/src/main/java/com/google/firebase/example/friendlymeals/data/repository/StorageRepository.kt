package com.google.firebase.example.friendlymeals.data.repository

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.datasource.StorageRemoteDataSource
import javax.inject.Inject

class StorageRepository @Inject constructor(
    private val storageRemoteDataSource: StorageRemoteDataSource
) {
    fun addImage(image: Bitmap, recipeId: String) {
        storageRemoteDataSource.addImage(image, recipeId)
    }

    suspend fun getImage(recipeId: String): Bitmap? {
        return storageRemoteDataSource.getImage(recipeId)
    }
}