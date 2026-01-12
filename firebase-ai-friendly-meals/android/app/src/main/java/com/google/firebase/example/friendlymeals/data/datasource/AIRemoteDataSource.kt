package com.google.firebase.example.friendlymeals.data.datasource

import android.graphics.Bitmap
import com.google.firebase.ai.FirebaseAI
import com.google.firebase.ai.GenerativeModel
import com.google.firebase.ai.ImagenModel
import com.google.firebase.ai.type.ImagePart
import com.google.firebase.ai.type.ImagenAspectRatio
import com.google.firebase.ai.type.ImagenImageFormat
import com.google.firebase.ai.type.ImagenPersonFilterLevel
import com.google.firebase.ai.type.ImagenSafetyFilterLevel
import com.google.firebase.ai.type.ImagenSafetySettings
import com.google.firebase.ai.type.ResponseModality
import com.google.firebase.ai.type.Schema
import com.google.firebase.ai.type.content
import com.google.firebase.ai.type.generationConfig
import com.google.firebase.ai.type.imagenGenerationConfig
import com.google.firebase.example.friendlymeals.data.schema.MealSchema
import com.google.firebase.example.friendlymeals.data.schema.RecipeSchema
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import kotlinx.serialization.json.Json
import javax.inject.Inject

class AIRemoteDataSource @Inject constructor(
    private val firebaseAI: FirebaseAI,
    private val remoteConfig: FirebaseRemoteConfig
) {
    private val json = Json { ignoreUnknownKeys = true }

    private val generativeModel: GenerativeModel get() =
        firebaseAI.generativeModel(
            modelName = remoteConfig.getString("model_name"),
            generationConfig = generationConfig {
                responseModalities = listOf(ResponseModality.TEXT, ResponseModality.IMAGE)
            }
        )

    private val imagenModel: ImagenModel get() =
        firebaseAI.imagenModel(
            modelName = remoteConfig.getString("imagen_name"),
            generationConfig = imagenGenerationConfig {
                numberOfImages = 1
                aspectRatio = ImagenAspectRatio.SQUARE_1x1
                imageFormat = ImagenImageFormat.png()
            },
            safetySettings = ImagenSafetySettings(
                safetyFilterLevel = ImagenSafetyFilterLevel.BLOCK_LOW_AND_ABOVE,
                personFilterLevel = ImagenPersonFilterLevel.BLOCK_ALL
            )
        )

    private val mealSchemaModel: GenerativeModel get() =
        firebaseAI.generativeModel(
            modelName = remoteConfig.getString("schema_model_name"),
            generationConfig = generationConfig {
                responseMimeType = "application/json"
                responseSchema = Schema.obj(
                    mapOf(
                        "protein" to Schema.string(),
                        "fat" to Schema.string(),
                        "carbs" to Schema.string(),
                        "sugar" to Schema.string(),
                        "ingredients" to Schema.array(Schema.string())
                    )
                )
            }
        )

    private val recipeSchemaModel: GenerativeModel get() =
        firebaseAI.generativeModel(
            modelName = remoteConfig.getString("schema_model_name"),
            generationConfig = generationConfig {
                responseMimeType = "application/json"
                responseSchema = Schema.obj(
                    mapOf(
                        "title" to Schema.string(),
                        "instructions" to Schema.string(),
                        "ingredients" to Schema.array(Schema.string()),
                        "prepTime" to Schema.string(),
                        "cookTime" to Schema.string(),
                        "servings" to Schema.string(),
                        "tags" to Schema.array(Schema.string())
                    )
                )
            }
        )

    suspend fun generateIngredients(image: Bitmap): String {
        val prompt = content {
            image(image)
            text("Please analyze this image and list all visible food ingredients. " +
                    "Format the response as a comma-separated list of ingredients. " +
                    "Be specific with measurements where possible, " +
                    "but focus on identifying the ingredients accurately.")
        }

        val response = generativeModel.generateContent(prompt)
        return response.text.orEmpty()
    }

    suspend fun generateRecipe(ingredients: String, notes: String): RecipeSchema? {
        var prompt = """
            Create a detailed recipe based on these ingredients: $ingredients.
            
            Format requirements:
            - 'instructions': Provide the cooking steps as a clear list of instructions separated by newlines. Use bold formatting on the step numbers. Use Markdown.
            - 'ingredients': List all necessary items, including quantities.
            - 'prepTime', 'cookTime', 'servings': Short strings (e.g., "15 mins").
            - 'tags': Generate a list of 3-5 relevant category tags (e.g., "Healthy", "Vegan", "Gluten-Free", "Dessert", "Quick").
        """.trimIndent()

        if (notes.isNotBlank()) {
            prompt += "\n\nIMPORTANT CUISINE AND DIETARY NOTES: $notes"
        }

        val response = recipeSchemaModel.generateContent(prompt)

        return response.text?.let {
            json.decodeFromString<RecipeSchema>(it)
        }
    }

    suspend fun generateRecipePhoto(recipeTitle: String): Bitmap? {
        val prompt = "A professional food photography shot of this recipe: $recipeTitle. " +
                "Style: High-end food photography, restaurant-quality plating, soft natural " +
                "lighting, on a clean background, showing the complete plated dish."

        return generativeModel.generateContent(prompt)
            .candidates.firstOrNull()?.content?.parts
            ?.filterIsInstance<ImagePart>()?.firstOrNull()?.image
    }

    suspend fun generateRecipePhotoImagen(recipeTitle: String): Bitmap? {
        val prompt = "A professional food photography shot of this recipe: $recipeTitle. " +
                "Style: High-end food photography, restaurant-quality plating, soft natural " +
                "lighting, on a clean background, showing the complete plated dish."

        val imageResponse = imagenModel.generateImages(prompt)
        return imageResponse.images.firstOrNull()?.asBitmap()
    }

    suspend fun scanMeal(image: Bitmap): MealSchema? {
        val prompt = content {
            image(image)
            text(
                """
                Analyze this image of a meal and estimate the nutritional content.
                Return the result in JSON format matching the schema:
                - protein, fat, carbs, sugar (strings with units, e.g., '20g')
                - ingredients (list of strings)
                """.trimIndent()
            )
        }

        val response = mealSchemaModel.generateContent(prompt)

        return response.text?.let {
            json.decodeFromString<MealSchema>(it)
        }
    }
}