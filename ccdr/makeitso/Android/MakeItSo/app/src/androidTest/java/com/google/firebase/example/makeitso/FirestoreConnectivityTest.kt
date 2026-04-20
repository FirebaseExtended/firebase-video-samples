package com.google.firebase.example.makeitso

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.tasks.await
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.util.*

import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.model.TaskPriority

@RunWith(AndroidJUnit4::class)
class FirestoreConnectivityTest {

    @Test
    fun testAuthAndFirestoreConnectivity() = runBlocking {
        val auth = FirebaseAuth.getInstance()
        val db = FirebaseFirestore.getInstance()

        // 1. Test Auth
        if (auth.currentUser == null) {
            auth.signInAnonymously().await()
        }
        val userId = auth.currentUser?.uid
        assertNotNull("User should be signed in", userId)
        println("Test: Signed in as $userId")

        // 2. Test Firestore Write using the real Task model
        val testTask = Task(
            title = "Integration Test Task ${UUID.randomUUID()}",
            userId = userId,
            isCompleted = false,
            priority = TaskPriority.Medium
        )

        val docRef = db.collection("tasks").add(testTask).await()
        assertNotNull("Document reference should not be null", docRef.id)
        println("Test: Task written with ID: ${docRef.id}")

        // 3. Test Firestore Read
        val snapshot = db.collection("tasks").document(docRef.id).get().await()
        assertTrue("Document should exist", snapshot.exists())
        val readTask = snapshot.toObject(Task::class.java)
        assertNotNull("Read task should not be null", readTask)
        assertEquals("Title should match", testTask.title, readTask?.title)
        println("Test: Task read back successfully")

        // Cleanup
        db.collection("tasks").document(docRef.id).delete().await()
        println("Test: Cleanup successful")
    }

    private fun assertEquals(message: String, expected: Any?, actual: Any?) {
        org.junit.Assert.assertEquals(message, expected, actual)
    }
}
