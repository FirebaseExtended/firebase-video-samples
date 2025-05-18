// Import the Genkit core libraries and plugins.
import { genkit, z } from "genkit";
import { gemini20Flash, textEmbedding005, vertexAI } from "@genkit-ai/vertexai";
import { defineFirestoreRetriever } from '@genkit-ai/firebase';
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onCallGenkit } from "firebase-functions/https";
import { onDocumentWritten } from "firebase-functions/firestore";
import { defineSecret } from "firebase-functions/params";
import { cert } from 'firebase-admin/app';

// Import models from the Vertex AI plugin. The Vertex AI API provides access to
// several generative models. Here, we import Gemini 1.5 Flash.

// Cloud Functions for Firebase supports Genkit natively. The onCallGenkit function creates a callable
// function from a Genkit action. It automatically implements streaming if your flow does.
// The https library also has other utility methods such as hasClaim, which verifies that
// a caller's token has a specific claim (optionally matching a specific value)

// Genkit models generally depend on an API key. APIs should be stored in Cloud Secret Manager so that
// access to these sensitive values can be controlled. defineSecret does this for you automatically.
// If you are using Google generative AI you can get an API key at https://aistudio.google.com/app/apikey
const apiKey = defineSecret("GOOGLE_GENAI_API_KEY");

// Initialize Firebase Admin
let app;
console.log('Environment details:');
console.log('- NODE_ENV:', process.env.NODE_ENV);
console.log('- FUNCTIONS_EMULATOR:', process.env.FUNCTIONS_EMULATOR);
console.log('- FIREBASE_CONFIG:', process.env.FIREBASE_CONFIG);
console.log('- GCLOUD_PROJECT:', process.env.GCLOUD_PROJECT);

// Check if we're running locally by looking for the service account file
const serviceAccountPath = '/Users/peterfriese/Workspace/products/VertexAI-Firebase/code/FriendlyMeals/service-accounts/service-account.json';
const isLocal = process.env.NODE_ENV === 'development' ||
	process.env.FUNCTIONS_EMULATOR === 'true' ||
	require('fs').existsSync(serviceAccountPath);

if (isLocal) {
	console.log('Initializing Firebase Admin with service account for local development');
	console.log('Service account path:', serviceAccountPath);
	try {
		app = initializeApp({
			credential: cert(serviceAccountPath),
			projectId: 'peterfriese-friendly-meals-04'
		});
	} catch (error) {
		console.error('Error initializing Firebase Admin with service account:', error);
		throw error;
	}
} else {
	console.log('Initializing Firebase Admin with default credentials for cloud environment');
	app = initializeApp();
}
console.log('Firebase Admin initialized successfully');
const firestore = getFirestore(app);

import { enableFirebaseTelemetry } from '@genkit-ai/firebase';

enableFirebaseTelemetry();

const ai = genkit({
	plugins: [
		// Load the Vertex AI plugin. You can optionally specify your project ID
		// by passing in a config object; if you don't, the Vertex AI plugin uses
		// the value from the GCLOUD_PROJECT environment variable.
		vertexAI({ location: "us-central1" }),
	],
	model: gemini20Flash
});

// Create a retriever for recipes
const recipeRetriever = defineFirestoreRetriever(ai, {
	name: 'recipeRetriever',
	firestore,
	collection: 'recipes',
	contentField: 'recipe',
	vectorField: 'ingredientsEmbeddings',
	embedder: textEmbedding005,
	distanceMeasure: 'COSINE'
});

// Define a schema for ingredient detection
const ingredientSchema = z.object({
	ingredients: z.array(z.object({
		name: z.string().describe("The name of the ingredient"),
		quantity: z.string().optional().describe("Amount of the ingredient"),
		unit: z.string().optional().describe("Unit of measurement (e.g., 'pieces', 'liters', 'grams')")
	}))
});

// Define a flow that detects ingredients from a fridge image
const detectIngredientsFlow = ai.defineFlow({
	name: "detectIngredientsFlow",
	inputSchema: z.object({
		image: z.string().describe("Base64 encoded image of a fridge or food items")
	}),
	outputSchema: ingredientSchema,
}, async (input) => {
	const prompt = `Analyze this image of a fridge or food items and list all the ingredients you can identify. 
	For each ingredient, provide:
	1. The name of the ingredient
	2. The amount and unit (if visible, e.g., "2 liters", "3 pieces", "500 grams")
	
	Format the response as a structured list of ingredients.`;

	const { output } = await ai.generate({
		prompt: [
			{
				media: {
					url: input.image
				}
			},
			{
				text: prompt
			}
		],
		output: { schema: ingredientSchema }
	});

	if (!output) {
		throw new Error("Failed to detect ingredients");
	}

	return output;
});

export const detectIngredients = onCallGenkit({
	secrets: [apiKey],
}, detectIngredientsFlow);

// Define a schema for recipe search results
const recipeSearchSchema = z.object({
	recipes: z.array(z.object({
		id: z.string(),
		title: z.string(),
		description: z.string(),
		cuisine: z.string(),
		cookingTimeInMinutes: z.number(),
		imageURL: z.string(),
		ingredientsList: z.array(z.string()),
		instructions: z.array(z.string()),
		score: z.number().optional()
	}))
});

// Function to compute embeddings for ingredients
const computeIngredientsEmbeddings = async (ingredientsList: string[]): Promise<number[]> => {
	const text = ingredientsList.join(", ");
	const result = await ai.embed({
		embedder: textEmbedding005,
		content: text,
	});
	return result[0].embedding;
};

// Function to format a recipe as markdown
const formatRecipeMarkdown = (recipe: {
	title: string;
	description: string;
	ingredientsList: string[];
	instructions: string[];
	cuisine: string;
	cookingTimeInMinutes: number;
}): string => {
	return `# ${recipe.title}

${recipe.description}

## Ingredients
${recipe.ingredientsList.map((ingredient: string) => `- ${ingredient}`).join('\n')}

## Instructions
${recipe.instructions.map((instruction: string, index: number) => `${index + 1}. ${instruction}`).join('\n')}

## Details
- Cuisine: ${recipe.cuisine}
- Cooking Time: ${recipe.cookingTimeInMinutes} minutes
`;
};

// Cloud Function to update embeddings when recipes are created or modified
export const updateRecipeEmbeddings = onDocumentWritten('recipes/{recipeId}', async (event) => {
	const snap = event.data?.after;
	if (!snap) return;

	const recipe = snap.data();
	if (!recipe || !recipe.ingredientsList) {
		console.log('No recipe data or ingredients found');
		return;
	}

	try {
		const ingredientsEmbeddings = await computeIngredientsEmbeddings(recipe.ingredientsList);
		// Concatenate all ingredients into a single string
		const ingredients = recipe.ingredientsList.join(", ");

		// Format the entire recipe in markdown
		const recipeMarkdown = formatRecipeMarkdown({
			title: recipe.title as string,
			description: recipe.description as string,
			ingredientsList: recipe.ingredientsList as string[],
			instructions: recipe.instructions as string[],
			cuisine: recipe.cuisine as string,
			cookingTimeInMinutes: recipe.cookingTimeInMinutes as number
		});

		await firestore.collection('recipes').doc(snap.id).update({
			ingredientsEmbeddings: FieldValue.vector(ingredientsEmbeddings),
			ingredients: ingredients, // Add the concatenated ingredients string
			recipe: recipeMarkdown // Add the markdown formatted recipe
		});
		console.log(`Updated embeddings, ingredients, and recipe markdown for recipe ${snap.id}`);
	} catch (error) {
		console.error(`Error updating embeddings, ingredients, and recipe markdown for recipe ${snap.id}:`, error);
		throw error;
	}
});


// Define a flow that finds recipes based on ingredients
const findRecipesFlow = ai.defineFlow({
	name: "findRecipesFlow",
	inputSchema: z.object({
		ingredientsList: z.array(z.string()).describe("List of ingredients to search for")
	}),
	outputSchema: recipeSearchSchema,
}, async (input) => {
	// Format ingredients to match how embeddings are computed
	const ingredientsList = input.ingredientsList.map(i => i.trim());
	const query = ingredientsList.join(", ");

	console.log('Searching for ingredients:', query);

	// Use the retriever to find matching recipes
	const docs = await ai.retrieve({
		retriever: recipeRetriever,
		query: query,
		options: {
			limit: 5, // Return up to 5 recipes
		},
	});

	console.log('Found documents:', docs.length);
	console.log('Documents:', docs);

	// Format the results
	const recipes = docs.map(doc => {
		const metadata = doc.metadata as {
			id: string;
			title: string;
			description: string;
			cuisine: string;
			cookingTimeInMinutes: number;
			imageURL: string;
			ingredientsList: string[];
			instructions: string[];
		};
		return {
			...metadata,
			score: doc.metadata?.score as number | undefined
		};
	});

	return { recipes };
});

export const findRecipes = onCallGenkit({
	secrets: [apiKey],
}, findRecipesFlow);

// Define a schema for recipe generation preferences
const recipeGenerationSchema = z.object({
	inspirationRecipes: recipeSearchSchema.describe("Array of existing recipes to use as inspiration"),
	cuisine: z.string().describe("The type of cuisine (e.g., Italian, Mexican, Indian)"),
	mealType: z.enum(['breakfast', 'lunch', 'dinner', 'dessert']).describe("Type of meal"),
	servings: z.number().min(1).describe("Number of people to feed"),
	dietaryRestrictions: z.array(z.string()).optional().describe("Optional dietary restrictions (e.g., vegetarian, gluten-free)"),
	detectedIngredients: ingredientSchema.describe("List of ingredients detected from the image")
});

// Define a flow that generates a new recipe based on preferences and inspiration recipes
const inventRecipeFlow = ai.defineFlow({
	name: "inventRecipeFlow",
	inputSchema: recipeGenerationSchema,
	outputSchema: recipeSearchSchema,
}, async (input) => {
	// Create a detailed prompt that includes both the inspiration recipes and user preferences
	const inspirationPrompt = input.inspirationRecipes.recipes.map(recipe =>
		`Recipe: ${recipe.title}
		Description: ${recipe.description}
		Ingredients: ${recipe.ingredientsList.join(', ')}
		Instructions: ${recipe.instructions.join('; ')}`
	).join('\n\n');

	const detectedIngredientsPrompt = input.detectedIngredients.ingredients.map(ingredient =>
		`- ${ingredient.name}${ingredient.quantity ? ` (${ingredient.quantity}${ingredient.unit ? ` ${ingredient.unit}` : ''})` : ''}`
	).join('\n');

	const prompt = `Create a new recipe inspired by the following recipes, but with these specific preferences:
	
	Inspiration Recipes:
	${inspirationPrompt}
	
	Available Ingredients:
	${detectedIngredientsPrompt}
	
	Preferences:
	- Cuisine: ${input.cuisine}
	- Meal Type: ${input.mealType}
	- Servings: ${input.servings}
	${input.dietaryRestrictions ? `- Dietary Restrictions: ${input.dietaryRestrictions.join(', ')}` : ''}
	
	Create a new, unique recipe that:
	1. Primarily uses the available ingredients listed above
	2. Combines elements from the inspiration recipes
	3. Matches the specified cuisine and meal type
	4. Serves the correct number of people
	5. Adheres to any dietary restrictions
	6. Has a creative and descriptive title
	7. Includes a brief description
	8. Lists all ingredients with precise measurements
	9. Provides clear, step-by-step cooking instructions
	10. Specifies the estimated cooking time in minutes
	11. Suggests an appropriate image URL
	
	Format the response as a structured recipe.`;

	const { output } = await ai.generate({
		prompt,
		output: { schema: recipeSearchSchema }
	});

	if (!output) {
		throw new Error("Failed to generate recipe");
	}

	// Since we're generating a single recipe, we'll wrap it in the expected format
	return {
		recipes: [{
			...output.recipes[0],
			id: crypto.randomUUID() // Generate a unique ID for the new recipe
		}]
	};
});

export const inventRecipe = onCallGenkit({
	secrets: [apiKey],
}, inventRecipeFlow);

// Define a schema for generating recipes from images
const imageBasedRecipeSchema = z.object({
	image: z.string().describe("Base64 encoded image of ingredients"),
	cuisine: z.string().describe("The type of cuisine (e.g., Italian, Mexican, Indian)"),
	mealType: z.enum(['breakfast', 'lunch', 'dinner', 'dessert']).describe("Type of meal"),
	servings: z.number().min(1).describe("Number of people to feed"),
	dietaryRestrictions: z.array(z.string()).optional().describe("Optional dietary restrictions (e.g., vegetarian, gluten-free)")
});

// Define a flow that generates a recipe from an image and preferences
const generateRecipeFlow = ai.defineFlow({
	name: "generateRecipeFlow",
	inputSchema: imageBasedRecipeSchema,
	outputSchema: recipeSearchSchema,
}, async (input) => {
	// Step 1: Detect ingredients from the image
	const detectedIngredients = await detectIngredientsFlow({
		image: input.image
	});

	// Step 2: Find inspiration recipes based on detected ingredients
	const inspirationRecipes = await findRecipesFlow({
		ingredientsList: detectedIngredients.ingredients.map(i => i.name)
	});

	// Step 3: Generate a new recipe using the inspiration recipes and preferences
	const generatedRecipe = await inventRecipeFlow({
		inspirationRecipes,
		cuisine: input.cuisine,
		mealType: input.mealType,
		servings: input.servings,
		dietaryRestrictions: input.dietaryRestrictions,
		detectedIngredients
	});

	return generatedRecipe;
});

export const generateRecipe = onCallGenkit({
	secrets: [apiKey],
}, generateRecipeFlow);
