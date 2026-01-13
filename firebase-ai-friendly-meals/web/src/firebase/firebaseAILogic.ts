import { getGenerativeModel, Schema, type Part } from "firebase/ai";
import { ai } from "./firebase";
import type { Recipe } from "../data";

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
      instructions: Schema.string(),
      tags: Schema.array({ items: Schema.string() }),
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

  const prompt = `Using the following list of ingredients, create a recipe in the ${cuisineType} cuisine: ${ingredients}`;

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

export async function generateTextRecipeWithImage(
  image: File | null,
  cuisineType: string
): Promise<string> {
  // Create a `GenerativeModel` instance with the desired model.
  const model = getGenerativeModel(ai, { model: "gemini-2.5-flash" });

  if (image) {
    // Convert image type
    const imagePart = await fileToGenerativePart(image);

    // Create the prompt sent to the LLM from a template.
    const prompt = `Using what you see in the image, create a recipe in the ${cuisineType} cuisine`;

    // To generate text output, call generateContent with the text and image
    const result = await model.generateContent([prompt, imagePart as Part]);

    return result.response.text();
  }

  return '';
}