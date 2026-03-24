package com.google.firebase.example.makeitso.data.datasource

import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.model.TaskList
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Filter
import com.google.firebase.firestore.Query
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

class DatabaseRemoteDataSource @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    private val tasksCollection get() = firestore.collection(TASKS_COLLECTION)
    private val listsCollection get() = firestore.collection(LISTS_COLLECTION)

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

    fun getTasks(userId: String, listId: String? = null): Flow<List<Task>> = callbackFlow {
        var query: Query = tasksCollection
        if (listId != null) {
            query = query.whereEqualTo(LIST_ID_FIELD, listId)
        } else {
            query = query.whereEqualTo(USER_ID_FIELD, userId)
        }

        val listener = query
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

    suspend fun saveList(list: TaskList) {
        listsCollection.add(list).await()
    }

    suspend fun updateList(list: TaskList) {
        if (list.id.isNotEmpty()) {
            listsCollection.document(list.id).set(list).await()
        } else {
            throw IllegalArgumentException("TaskList ID cannot be empty for update operation.")
        }
    }

    suspend fun deleteList(listId: String) {
        listsCollection.document(listId).delete().await()
    }

    fun getLists(userId: String): Flow<List<TaskList>> = callbackFlow {
        val listener = listsCollection
            .where(Filter.or(
                Filter.equalTo(USER_ID_FIELD, userId),
                Filter.arrayContains("sharedWith", userId)
            ))
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    close(error)
                    return@addSnapshotListener
                }
                if (snapshot != null) {
                    val lists = snapshot.toObjects(TaskList::class.java)
                    trySend(lists)
                }
            }
        awaitClose { listener.remove() }
    }

    companion object {
        private const val USER_ID_FIELD = "userId"
        private const val LIST_ID_FIELD = "listId"
        private const val TASKS_COLLECTION = "tasks"
        private const val LISTS_COLLECTION = "lists"
    }
}
