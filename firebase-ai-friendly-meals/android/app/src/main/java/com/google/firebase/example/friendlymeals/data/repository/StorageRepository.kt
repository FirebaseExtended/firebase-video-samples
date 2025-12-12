package com.google.firebase.example.friendlymeals.data.repository

import android.graphics.Bitmap
import com.google.firebase.example.friendlymeals.data.datasource.StorageRemoteDataSource
import javax.inject.Inject

class StorageRepository @Inject constructor(
    private val storageRemoteDataSource: StorageRemoteDataSource
) {
    fun storeImage(image: Bitmap, recipeId: String) {
        storageRemoteDataSource.storeImage(image, recipeId)
    }

    fun retrieveImage(recipeId: String): Bitmap? {
        return storageRemoteDataSource.retrieveImage(recipeId)
    }
}