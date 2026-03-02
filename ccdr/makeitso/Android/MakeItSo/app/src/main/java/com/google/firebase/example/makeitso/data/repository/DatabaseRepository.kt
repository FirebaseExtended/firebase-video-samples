package com.google.firebase.example.makeitso.data.repository

import com.google.firebase.example.makeitso.data.datasource.DatabaseRemoteDataSource
import com.google.firebase.example.makeitso.data.model.Task
import javax.inject.Inject

class DatabaseRepository @Inject constructor(
    private val databaseRemoteDataSource: DatabaseRemoteDataSource
) {
    fun getTasks(userId: String, listId: String? = null) = databaseRemoteDataSource.getTasks(userId, listId)
    suspend fun saveTask(task: Task) = databaseRemoteDataSource.saveTask(task)
    suspend fun updateTask(task: Task) = databaseRemoteDataSource.updateTask(task)
    suspend fun deleteTask(taskId: String) = databaseRemoteDataSource.deleteTask(taskId)

    fun getLists(userId: String) = databaseRemoteDataSource.getLists(userId)
    suspend fun saveList(list: TaskList) = databaseRemoteDataSource.saveList(list)
    suspend fun updateList(list: TaskList) = databaseRemoteDataSource.updateList(list)
    suspend fun deleteList(listId: String) = databaseRemoteDataSource.deleteList(listId)
}