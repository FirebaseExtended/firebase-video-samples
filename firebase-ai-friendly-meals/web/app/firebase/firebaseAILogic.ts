import { getGenerativeModel, Schema, type Part, ResponseModality } from "firebase/ai";
import { ai, storage } from "./firebase";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import type { Recipe } from "./data";
// Tags are now dynamic and fetched from the database when needed for display


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

// Generates a header image for the recipe and saves it to Firebase Storage
export async function generateRecipeImage(title: string): Promise<string> {
  const model = getGenerativeModel(ai, {
    model: "gemini-2.5-flash-image",
    generationConfig: {
      responseModalities: [ResponseModality.TEXT, ResponseModality.IMAGE],
    },
  });

  const prompt = `Generate a high-quality, professional image for a "${title}" recipe. The image should be well-lit and make the food look delicious.`;

  const result = await model.generateContent(prompt);

  try {
    const inlineDataParts = result.response.inlineDataParts();
    if (inlineDataParts?.[0]) {
      const { data, mimeType } = inlineDataParts[0].inlineData;

      // Convert base64 to Blob
      const byteCharacters = atob(data);
      const byteNumbers = new Array(byteCharacters.length);
      for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
      }
      const byteArray = new Uint8Array(byteNumbers);
      const blob = new Blob([byteArray], { type: mimeType });

      // Save to Firebase Storage
      const filename = `recipe_images/${Date.now()}_${title.replace(/\s+/g, '_').toLowerCase()}.png`;
      const storageRef = ref(storage, filename);
      await uploadBytes(storageRef, blob, { contentType: mimeType });
      const downloadURL = await getDownloadURL(storageRef);

      return downloadURL;
    }
  } catch (err) {
    console.error('Image generation or upload failed:', err);
  }

  return ""; // Fallback
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

  const prompt = `Using the following list of ingredients, create a recipe in the ${cuisineType} cuisine: ${ingredients}.`;

  const result = await model.generateContent(prompt);

  const recipe = JSON.parse(result.response.text());

  // Generate and add header image
  if (recipe.title) {
    recipe.imageUri = await generateRecipeImage(recipe.title);
  }

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
      tags: Schema.array({ items: Schema.string() }),
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
    const recipe = JSON.parse(result.response.text());

    // Generate and add header image
    if (recipe.title) {
      recipe.imageUri = await generateRecipeImage(recipe.title);
    }

    return recipe;
  }

  throw new Error("No image provided");
}