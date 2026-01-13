import { initializeFirestore, addDoc, collection, getDoc, doc, deleteDoc, updateDoc, persistentLocalCache } from "firebase/firestore";
import { execute, field } from "firebase/firestore/pipelines";
import { firebaseApp } from "./firebase";

export interface Review {
    id: string;
    userId: string;
    rating: number;
    text: string;
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

export interface RecipeFilters {
    name?: string;
    minRating?: number;
    tags?: string[];
    sortBy?: 'rating' | 'title';
}

export const db = initializeFirestore(firebaseApp, { localCache: persistentLocalCache({}) }, 'default');

export async function getRecipes(userId: string, filters?: RecipeFilters): Promise<Recipe[]> {
    let pipeline = db.pipeline()
        .collection(`users/${userId}/recipes`);

    // Apply rating filter
    if (filters?.minRating && filters.minRating > 0) {
        pipeline = pipeline.where(field("averageRating").greaterThanOrEqual(filters.minRating));
    }

    // Apply tags filter
    if (filters?.tags && filters.tags.length > 0) {
        pipeline = pipeline.where(field("tags").arrayContainsAny(filters.tags));
    }

    // Apply sorting
    if (filters?.sortBy === 'rating') {
        pipeline = pipeline.sort(field("averageRating").descending());
    } else if (filters?.sortBy === 'title') {
        pipeline = pipeline.sort(field("title").ascending());
    }

    const { results } = await execute(pipeline);
    let recipes = results.map(result => {
        return { ...result.data(), id: result.id } as Recipe
    });

    // Client-side name filtering (substring match)
    if (filters?.name && filters.name.trim() !== '') {
        const searchTerm = filters.name.toLowerCase();
        recipes = recipes.filter(recipe =>
            recipe.title.toLowerCase().includes(searchTerm)
        );
    }

    return recipes;
}

export async function saveRecipe(userId: string, recipe: Omit<Recipe, "id">): Promise<string> {
    const recipeRef = await addDoc(collection(db, `users/${userId}/recipes`), recipe);
    console.log('saved recipe', recipeRef.id);
    return recipeRef.id;
}

export async function getRecipe(userId: string, recipeId: string): Promise<Recipe | null> {
    const recipeRef = doc(db, `users/${userId}/recipes/${recipeId}`);
    const recipeSnapshot = await getDoc(recipeRef);
    if (recipeSnapshot.exists()) {
        return { ...recipeSnapshot.data(), id: recipeSnapshot.id } as Recipe;
    }
    return null;
}

export async function deleteRecipe(userId: string, recipeId: string) {
    await deleteDoc(doc(db, `users/${userId}/recipes/${recipeId}`));
}

export async function updateRecipeRating(userId: string, recipeId: string, rating: number) {
    const recipeRef = doc(db, `users/${userId}/recipes/${recipeId}`);
    await updateDoc(recipeRef, { averageRating: rating });
}