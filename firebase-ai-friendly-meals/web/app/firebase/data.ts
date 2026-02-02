import { initializeFirestore, addDoc, collection, getDoc, doc, deleteDoc, updateDoc, persistentLocalCache, setDoc, getDocs, query, where, runTransaction, increment } from "firebase/firestore";
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

// Get top 5 most popular tags across all recipes
export async function getTop5Tags(): Promise<string[]> {
    const pipeline = db.pipeline()
        .collection("recipes")
        .unnest(field("tags").as("tagName"))
        .aggregate({
            accumulators: [countAll().as("tagCount")],
            groups: ["tagName"]
        })
        .sort(field("tagCount").descending())
        .limit(5);

    const { results } = await execute(pipeline);
    return results.map(result => result.data().tagName as string);
}

export async function publishRecipe(userId: string, recipe: Omit<Recipe, "id">): Promise<string> {
    const recipeRef = await addDoc(collection(db, "recipes"), {
        ...recipe,
        authorId: userId
    });
    return recipeRef.id;
}

export async function getRecipe(recipeId: string): Promise<Recipe | null> {
    const recipeRef = doc(db, `recipes/${recipeId}`);
    const recipeSnapshot = await getDoc(recipeRef);

    if (!recipeSnapshot.exists()) {
        return null;
    }

    const recipeData = recipeSnapshot.data() as Recipe;
    return {
        ...recipeData,
        id: recipeSnapshot.id,
    } as Recipe;
}

export async function deleteRecipe(recipeId: string) {
    await deleteDoc(doc(db, `recipes/${recipeId}`));
}

export async function addReview(recipeId: string, userId: string, rating: number, text?: string) {
    // add the new review
    await addDoc(collection(db, `recipes/${recipeId}/reviews`), {
        recipeId,
        userId,
        rating,
        text: text || ""
    });

    // get the new average of all reviews
    const pipeline = db.pipeline()
        .collection(`recipes/${recipeId}/reviews`)
        .aggregate(field("rating").average().as("averageRating"));
    const { results } = await execute(pipeline);
    const data = results[0]?.data();

    let average = data && 'averageRating' in data ? data.averageRating as number : null;
    if (!average) {
        // there isn't an average yet, so set it to our new review score
        average = rating;
    }

    // set the new average rating
    await runTransaction(db, async transaction => {
        const recipeRef = doc(db, `recipes/${recipeId}`);
        transaction.update(recipeRef, { averageRating: average });
    });
}

export async function likeRecipe(userId: string, recipeId: string) {
    const likeId = `${recipeId}_${userId}`;
    await setDoc(doc(db, "saves", likeId), {
        userId,
        recipeId
    });


    // increment the total likes on the recipe itself
    const recipeRef = doc(db, `recipes/${recipeId}`);
    await updateDoc(recipeRef, { saves: increment(1) });
}

export async function unlikeRecipe(userId: string, recipeId: string) {
    const likeId = `${recipeId}_${userId}`;
    await deleteDoc(doc(db, "saves", likeId));

    // decrement the total likes on the recipe itself
    const recipeRef = doc(db, `recipes/${recipeId}`);
    await updateDoc(recipeRef, { saves: increment(-1) });
}

export async function isRecipeLikedByUser(userId: string, recipeId: string): Promise<boolean> {
    const pipeline = db.pipeline()
        .collection("saves")
        .where(field("userId").equal(userId))
        .where(field("recipeId").equal(recipeId))
        .limit(1);

    const { results } = await execute(pipeline);
    return results.length > 0;
}

export async function queryRecipes(filters: {
    searchTerm?: string;
    minRating?: number;
    tags?: string[];
    authorId?: string;
    savedOnly?: true;
    sort?: string;
}): Promise<Recipe[]> {
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
            pipeline = pipeline.sort(field('title').ascending());
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