import type { Route } from "./+types/recipes";
import Recipes from "../components/Recipes";
import { getAllRecipesForDisplay, queryRecipes, getLikedRecipeIds } from "../firebase/data";
import { getUser } from "../firebase/auth";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "All Recipes - Friendly Meals" },
        { name: "description", content: "Browse all recipes" },
    ];
}

export async function clientLoader({ request }: Route.ClientLoaderArgs) {
    const user = await getUser(); // Still require auth
    const url = new URL(request.url);

    const myRecipes = url.searchParams.get('myRecipes') === 'true';

    const filters = {
        minRating: url.searchParams.get('minRating') ? Number(url.searchParams.get('minRating')) : undefined,
        tags: url.searchParams.get('tags') ? url.searchParams.get('tags')!.split(',') : undefined,
        authorId: myRecipes ? user.uid : undefined
    };

    const likedOnly = url.searchParams.get('likedOnly') === 'true';

    let recipes: any[] = [];
    // If we have any filters, use queryRecipes
    if (filters.minRating || (filters.tags && filters.tags.length > 0) || filters.authorId) {
        recipes = await queryRecipes(filters);
    } else {
        // Fallback to basic get all if no filters active 
        recipes = await getAllRecipesForDisplay();
    }

    if (likedOnly) {
        const likedIds = await getLikedRecipeIds(user.uid);
        recipes = recipes.filter(r => likedIds.includes(r.id));
    }

    return recipes;
}


export default function RecipesPage() {
    return <Recipes />;
}
