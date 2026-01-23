import { getGenerativeModel, Schema, type Part } from "firebase/ai";
import { ai } from "./firebase";
import type { Recipe } from "./data";
import { AVAILABLE_TAGS } from "@/components/Recipes";

// Calls Gemini to return text recipe based on ingredients and cuisine type
export async function generateTextRecipe(
  ingredients: string,
  cuisineType: string
): Promise<string> {
  // Create a `GenerativeModel` instance with the desired model.
  const model = getGenerativeModel(ai, { model: "gemini-2.5-flash" });

  // Create the prompt sent to the LLM from a template.
  const prompt = `Using the following list of ingredients, create a recipe in the ${cuisineType} cuisine: ${ingredients}`;

  const result = await model.generateContent(prompt);
  const recipe = result.response.text();
  return recipe;
}

// Calls Gemini to return JSON based on ingredients and cuisine type
export async function generateStructuredJsonRecipe(
  ingredients: string,
  cuisineType: string
): Promise<Recipe> {

  // Create a schema describing the response type
  const recipeSchema = Schema.object({
    properties: {
      title: Schema.string(),
      ingredients: Schema.array({ items: Schema.string() }),
      instructions: Schema.string({ description: 'markdown-formatted recipe instructions.' }),
      tags: Schema.array({ items: Schema.enumString({ enum: AVAILABLE_TAGS }) }),
      prepTime: Schema.number(),
      cookTime: Schema.number(),
      servings: Schema.number(),
    },
  });

  // Create a `GenerativeModel` instance with a model configured to use your schema
  const model = getGenerativeModel(ai, {
    model: "gemini-2.5-flash",
    generationConfig: {
      responseMimeType: "application/json",
      responseSchema: recipeSchema,
    },
  });

  const prompt = `Using the following list of ingredients, create a recipe in the ${cuisineType} cuisine: ${ingredients}.`;

  const result = await model.generateContent(prompt);

  const recipe = JSON.parse(result.response.text());
  return recipe;
}

// Converts a File object to a Part object.
async function fileToGenerativePart(file: File) {
  const base64EncodedDataPromise = new Promise((resolve) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result ? (reader.result as String).split(',')[1] : '');
    reader.readAsDataURL(file);
  });
  return {
    inlineData: { data: await base64EncodedDataPromise, mimeType: file.type },
  };
}

export async function generateRecipeFromImage(
  image: File | null,
  cuisineType: string
): Promise<Recipe> {
  // Reuse the schema logic (duplicated for now as schema object isn't exported easily without refactor)
  const recipeSchema = Schema.object({
    properties: {
      title: Schema.string(),
      ingredients: Schema.array({ items: Schema.string() }),
      instructions: Schema.string(),
      tags: Schema.array({ items: Schema.enumString({ enum: AVAILABLE_TAGS }) }),
      prepTime: Schema.number(),
      cookTime: Schema.number(),
      servings: Schema.number(),
    },
  });

  const model = getGenerativeModel(ai, {
    model: "gemini-2.5-flash",
    // Use the schema for image generation too
    generationConfig: {
      responseMimeType: "application/json",
      responseSchema: recipeSchema,
    },
  });

  if (image) {
    const imagePart = await fileToGenerativePart(image);
    const prompt = `Using what you see in the image, create a recipe in the ${cuisineType} cuisine.`;
    const result = await model.generateContent([prompt, imagePart as Part]);
    return JSON.parse(result.response.text());
  }

  throw new Error("No image provided");
}