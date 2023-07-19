package com.notes.app.model

import com.google.firebase.firestore.DocumentId

private const val TITLE_MAX_SIZE = 30

data class Note(
    @DocumentId val id: String = "",
    val text: String = "",
    val userId: String = ""
)

fun Note.getTitle(): String {
    val isLongText = this.text.length > TITLE_MAX_SIZE
    val endRange = if (isLongText) TITLE_MAX_SIZE else this.text.length - 1
    return this.text.substring(IntRange(0, endRange))
}