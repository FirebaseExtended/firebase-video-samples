package com.google.firebase.example.makeitso.data.model

import com.google.firebase.firestore.DocumentId
import com.google.firebase.firestore.ServerTimestamp
import java.util.Date

enum class TaskPriority(val value: String) {
    LOW("Low"),
    MEDIUM("Medium"),
    HIGH("High");

    override fun toString(): String = value
}

data class Task(
    @DocumentId val id: String = "",
    val title: String = "",
    val description: String = "",
    val isCompleted: Boolean = false,
    val priority: TaskPriority = TaskPriority.LOW,
    val dueDate: Date? = null,
    @ServerTimestamp val createdAt: Date? = null,
    val userId: String? = null
)
