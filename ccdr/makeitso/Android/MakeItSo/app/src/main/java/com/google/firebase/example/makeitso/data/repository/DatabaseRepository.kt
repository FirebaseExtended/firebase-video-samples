package com.google.firebase.example.makeitso.data.repository

import com.google.firebase.example.makeitso.data.datasource.DatabaseRemoteDataSource
import com.google.firebase.example.makeitso.data.model.Task
import javax.inject.Inject

class DatabaseRepository @Inject constructor(
    private val databaseRemoteDataSource: DatabaseRemoteDataSource
) {
    fun getTasks(userId: String) = databaseRemoteDataSource.getTasks(userId)
    suspend fun saveTask(task: Task) = databaseRemoteDataSource.saveTask(task)
    suspend fun updateTask(task: Task) = databaseRemoteDataSource.updateTask(task)
    suspend fun deleteTask(taskId: String) = databaseRemoteDataSource.deleteTask(taskId)
}