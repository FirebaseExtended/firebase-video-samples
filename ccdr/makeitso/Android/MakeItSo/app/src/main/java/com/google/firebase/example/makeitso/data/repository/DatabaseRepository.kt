package com.google.firebase.example.makeitso.data.repository

import com.google.firebase.example.makeitso.data.datasource.DatabaseRemoteDataSource
import javax.inject.Inject

class DatabaseRepository @Inject constructor(
    private val databaseRemoteDataSource: DatabaseRemoteDataSource
) {

}