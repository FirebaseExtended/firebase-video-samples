package com.google.firebase.example.makeitso.data.model

import com.google.firebase.firestore.DocumentId
import com.google.firebase.firestore.PropertyName
import com.google.firebase.firestore.ServerTimestamp
import java.util.Date

enum class TaskPriority() {
    Low, Medium, High;
}

data class Task(
    @DocumentId val id: String = "",
    val title: String = "",
    val description: String = "",
    @get:PropertyName("isCompleted") val isCompleted: Boolean = false,
    val priority: TaskPriority = TaskPriority.Low,
    val dueDate: Date? = null,
    @ServerTimestamp val createdAt: Date? = null,
    val userId: String? = null
)
