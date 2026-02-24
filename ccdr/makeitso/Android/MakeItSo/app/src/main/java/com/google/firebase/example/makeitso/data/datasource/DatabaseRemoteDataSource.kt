package com.google.firebase.example.makeitso.data.datasource

import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

class DatabaseRemoteDataSource @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    private val tasksCollection get() = firestore.collection(TASKS_COLLECTION)

    suspend fun saveTask(task: Task) {
        tasksCollection.add(task).await()
    }

    suspend fun updateTask(task: Task) {
        if (task.id.isNotEmpty()) {
            tasksCollection.document(task.id).set(task).await()
        } else {
            throw IllegalArgumentException("Task ID cannot be empty for update operation.")
        }
    }

    suspend fun deleteTask(taskId: String) {
        tasksCollection.document(taskId).delete().await()
    }

    fun getTasks(userId: String): Flow<List<Task>> = callbackFlow {
        val listener = tasksCollection
            .whereEqualTo(USER_ID_FIELD, userId)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    close(error)
                    return@addSnapshotListener
                }
                if (snapshot != null) {
                    val tasks = snapshot.toObjects(Task::class.java)
                    trySend(tasks)
                }
            }
        awaitClose { listener.remove() }
    }

    companion object {
        private const val USER_ID_FIELD = "userId"
        private const val TASKS_COLLECTION = "tasks"
    }
}