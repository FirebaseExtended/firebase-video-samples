package com.google.firebase.example.makeitso.data.model

import com.google.firebase.firestore.DocumentId

data class TaskList(
    @DocumentId val id: String = "",
    val title: String = "",
    val userId: String = "",
    val shareToken: String? = null,
    val sharedWith: List<String> = emptyList()
)
