import { initializeFirestore, addDoc, collection, getDoc, doc, deleteDoc, updateDoc, persistentLocalCache, setDoc, getDocs, query, where } from "firebase/firestore";
import { execute, field, countAll } from "firebase/firestore/pipelines";
import { firebaseApp } from "./firebase";

export interface Review {
    recipeId: string;
    userId: string;
    rating: number;
    // Keeping text/id as they are useful, but strictly following spec for fields to mention
    text?: string;
    id?: string;
}

export interface Like {
    recipeId: string;
    userId: string;
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

export const db = initializeFirestore(firebaseApp, {}, 'default');

// Get all recipes for display (shows all recipes in database)
export async function getAllRecipesForDisplay(): Promise<Recipe[]> {
    const pipeline = db.pipeline()
        .collection("recipes");

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

// Search/filter recipes (all recipes, not user-specific)
export async function searchRecipes(minRating: number, tagNames: string[]): Promise<Recipe[]> {
    const pipeline = db.pipeline()
        .collection("recipes")
        .where(field("averageRating").greaterThanOrEqual(minRating))
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

// Get top 5 most popular tags across all recipes
export async function getTop5Tags(): Promise<string[]> {
    const pipeline = db.pipeline()
        .collection("recipes")
        // Unnest each tag within the `tags` array to its own document.
        .unnest(field("tags").as("tagName"))
        // Count the number of instances of each tag across recipes and
        // consolidate documents sharing a tagName into a single document
        // per tagName.
        .aggregate({
            accumulators: [countAll().as("tagCount")],
            groups: ["tagName"]
        })
        // Sort the resulting tags by their count.
        .sort(field("tagCount").descending())
        // Limit query results to just the top ten tags.
        .limit(5);

    const { results } = await execute(pipeline);
    return results.map(result => result.data().tagName as string);
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

// Like functionality
export async function likeRecipe(userId: string, recipeId: string) {
    const likeId = `${recipeId}_${userId}`;
    console.log(recipeId, userId);
    await setDoc(doc(db, "saves", likeId), {
        userId,
        recipeId
    });
}

export async function unlikeRecipe(userId: string, recipeId: string) {
    const likeId = `${recipeId}_${userId}`;
    await deleteDoc(doc(db, "saves", likeId));
}

export async function isRecipeLiked(userId: string, recipeId: string): Promise<boolean> {
    const likeId = `${recipeId}_${userId}`;
    const likeDoc = await getDoc(doc(db, "saves", likeId));
    return likeDoc.exists();
}

export async function getLike(recipeId: string): Promise<boolean> {
    const allLikes = await getLikedRecipeIds(recipeId);
    return allLikes.includes(recipeId);
}

export async function getLikedRecipeIds(userId: string): Promise<string[]> {
    const q = query(collection(db, "saves"), where("userId", "==", userId));
    const querySnapshot = await getDocs(q);
    return querySnapshot.docs.map(doc => doc.data().recipeId);
}

export interface RecipeFilters {
    searchTerm?: string;
    minRating?: number;
    tags?: string[];
    authorId?: string;
    savedOnly?: true;
    sort?: string;
}

export async function queryRecipes(filters: RecipeFilters): Promise<Recipe[]> {
    let pipeline = db.pipeline().collection("recipes");

    if (filters.authorId) {
        pipeline = pipeline.where(field("authorId").equal(filters.authorId));
    }

    if (filters.searchTerm) {
        pipeline = pipeline.where(field("title").like(`%${filters.searchTerm}%`));
    }

    if (filters.minRating && filters.minRating > 0) {
        pipeline = pipeline.where(field("averageRating").greaterThanOrEqual(filters.minRating));
    }

    if (filters.tags && filters.tags.length > 0) {
        pipeline = pipeline.where(field("tags").arrayContainsAny(filters.tags));
    }

    switch (filters.sort) {
        case 'title':
            pipeline = pipeline.sort(field('title').descending());
            break;
        case 'rating':
            pipeline = pipeline.sort(field('averageRating').descending());
            break;
        case 'saves':
            pipeline = pipeline.sort(field('saves').descending());
            break;
    }

    const { results } = await execute(pipeline);
    return results.map(result => ({ ...result.data(), id: result.id }) as Recipe);
}