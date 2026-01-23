import { initializeFirestore, addDoc, collection, getDoc, doc, deleteDoc, updateDoc, persistentLocalCache } from "firebase/firestore";
import { execute, field } from "firebase/firestore/pipelines";
import { firebaseApp } from "./firebase";

export interface Review {
    recipeId: string;
    userId: string;
    rating: number;
    // Keeping text/id as they are useful, but strictly following spec for fields to mention
    text?: string;
    id?: string;
}

export interface User {
    authId: string;
    id?: string;
}

export interface Save {
    recipeId: string;
    userId: string;
    id?: string;
}

export interface Recipe {
    id: string;
    title: string;
    instructions: string;
    ingredients: string[];
    authorId: string;
    tags: string[];
    averageRating: number;
    saves: number;
    prepTime: string;
    cookTime: string;
    servings: string;
    imageUri?: string;
}

export const db = initializeFirestore(firebaseApp, { localCache: persistentLocalCache({}) }, 'default');

// Recipes for user
export async function getRecipesForUser(userId: string): Promise<Recipe[]> {
    const pipeline = db.pipeline()
        .collection("recipes")
        .where(field("authorId").equal(userId));

    const { results } = await execute(pipeline);
    return results.map(result => ({ ...result.data(), id: result.id }) as Recipe);
}

// Recipes for tags
export async function getRecipesByTags(tagNames: string[]): Promise<Recipe[]> {
    const pipeline = db.pipeline()
        .collection("recipes")
        .where(field("tags").arrayContainsAny(tagNames));

    const { results } = await execute(pipeline);
    return results.map(result => ({ ...result.data(), id: result.id }) as Recipe);
}

// Example recipes filter (Search)
export async function searchRecipes(authorId: string, minRating: number, tagNames: string[]): Promise<Recipe[]> {
    const pipeline = db.pipeline()
        .collection("recipes")
        .where(field("authorId").equal(authorId)) // Corrected from authorName as per instruction
        .where(field("averageRating").greaterThan(minRating))
        .where(field("tags").arrayContainsAny(tagNames))
        .sort(field("saves").descending());

    const { results } = await execute(pipeline);
    return results.map(result => ({ ...result.data(), id: result.id }) as Recipe);
}

// Top tags for user
export async function getTopTagsForUser(userId: string): Promise<any[]> {
    // Sorts tags for a user's recipes by order of most to least mentioned, but does not
    // preserve quantities for each tag.
    const pipeline = db.pipeline()
        .collection("recipes")
        .where(field("authorId").equal(userId))
        .unnest(field("tags").as("unnestedTags"), /* index_field= */ "tagIndex")
        .sort(field("tagIndex").descending())
        .distinct(field("title"));

    const { results } = await execute(pipeline);
    return results.map(result => result.data());
}

// Reviews for user
export async function getReviewsForUser(userId: string): Promise<Review[]> {
    const pipeline = db.pipeline()
        .collectionGroup("reviews")
        .where(field("userId").equal(userId));

    const { results } = await execute(pipeline);
    return results.map(result => ({ ...result.data(), id: result.id }) as Review);
}

// Rating for recipe
export async function getRecipeAverageRating(recipeId: string): Promise<number | null> {
    const pipeline = db.pipeline()
        .collection(`recipes/${recipeId}/reviews`)
        .aggregate(field("rating").average().as("averageRating"));

    const { results } = await execute(pipeline);
    const data = results[0]?.data();
    console.log(data);
    return data && 'averageRating' in data ? data.averageRating as number : null;
}

// Helper query function for the old generic filter, mapped to new schema approximately or replaced.
// Since the prompt asked specifically for the exported functions for the queries, we can keep
// a generic getRecipes if needed but it must use the new root collection.
export async function getAllRecipes(): Promise<Recipe[]> {
    const pipeline = db.pipeline().collection("recipes");
    const { results } = await execute(pipeline);
    return results.map(result => ({ ...result.data(), id: result.id }) as Recipe);
}

// --- CRUD Operations updated for new Schema ---

export async function saveRecipe(userId: string, recipe: Omit<Recipe, "id">): Promise<string> {
    // Note: 'saves' collection is for users saving recipes, but creating a recipe goes to 'recipes' collection.
    // The previous implementation inferred "saving a recipe" meant "creating a recipe".
    // I will assume saveRecipe implies creating a recipe in the 'recipes' root collection now.
    const recipeRef = await addDoc(collection(db, "recipes"), {
        ...recipe,
        authorId: userId // Ensure authorId is set
    });
    console.log('saved recipe', recipeRef.id);
    return recipeRef.id;
}

export async function getRecipe(recipeId: string): Promise<Recipe | null> {
    const recipeRef = doc(db, `recipes/${recipeId}`);
    const recipeSnapshot = await getDoc(recipeRef);

    if (recipeSnapshot.exists()) {
        const recipeData = recipeSnapshot.data() as Recipe;
        // Fetch the dynamic average rating
        const avgRating = await getRecipeAverageRating(recipeId);

        return {
            ...recipeData,
            id: recipeSnapshot.id,
            // Use dynamic rating if available, fallback to stored rating or 0
            averageRating: avgRating !== null ? avgRating : (recipeData.averageRating || 0)
        } as Recipe;
    }
    return null;
}

export async function deleteRecipe(recipeId: string) {
    await deleteDoc(doc(db, `recipes/${recipeId}`));
}

// Example update: rating is now aggregated, but if we still store it on the recipe:
export async function updateRecipeRating(recipeId: string, rating: number) {
    const recipeRef = doc(db, `recipes/${recipeId}`);
    await updateDoc(recipeRef, { averageRating: rating });
}

// Function to add a review, as per schema 'reviews' subcollection off of recipes
export async function addReview(recipeId: string, userId: string, rating: number, text?: string) {
    await addDoc(collection(db, `recipes/${recipeId}/reviews`), {
        recipeId,
        userId,
        rating,
        text: text || ""
    });
}

// Function to save a recipe for a user (bookmarking) - 'saves' collection
export async function bookmarkRecipe(userId: string, recipeId: string) {
    await addDoc(collection(db, "saves"), {
        userId,
        recipeId
    });
}