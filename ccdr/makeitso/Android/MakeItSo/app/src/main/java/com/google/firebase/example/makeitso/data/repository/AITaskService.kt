package com.google.firebase.example.makeitso.data.repository

import com.google.firebase.Firebase
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.generationConfig
import com.google.firebase.ai.type.Schema
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString
import javax.inject.Inject

class AITaskService @Inject constructor() {
    private val responseSchema = Schema.array(
        items = Schema.string(description = "A single actionable, independent, top-level task to be done")
    )
    
    private val config = generationConfig {
        responseMimeType = "application/json"
        responseSchema = this@AITaskService.responseSchema
    }
    
    // Initialize Firebase AI Logic with the Google AI Developer API backend and gemini-2.5-flash
    private val model = Firebase.ai(backend = GenerativeBackend.googleAI()).generativeModel(
        modelName = "gemini-2.5-flash",
        generationConfig = config
    )
    
    suspend fun breakDownTask(title: String): List<String> {
        val prompt = """
            Break down the following complex task into exactly 4-6 simple, actionable, and concrete top-level tasks.
            
            Task: "$title"
        """.trimIndent()
        
        val response = model.generateContent(prompt)
        val responseText = response.text ?: return emptyList()
        
        return try {
            Json.decodeFromString<List<String>>(responseText)
        } catch (e: Exception) {
            emptyList()
        }
    }
}
