import type { Route } from "./+types/recipes";
import Recipes from "../components/Recipes";
import { getRecipesForUser, searchRecipes } from "../firebase/data";
import { getUser } from "../firebase/auth";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "My Recipes - Friendly Meals" },
        { name: "description", content: "Browse your saved recipes" },
    ];
}

export async function clientLoader({ request }: Route.ClientLoaderArgs) {
    const user = await getUser();
    const url = new URL(request.url);
    const filters = {
        name: url.searchParams.get('q') || undefined,
        minRating: url.searchParams.get('minRating') ? Number(url.searchParams.get('minRating')) : undefined,
        tags: url.searchParams.get('tags') ? url.searchParams.get('tags')!.split(',') : undefined,
        sortBy: (url.searchParams.get('sort') as 'rating' | 'title') || undefined,
    };

    // Use searchRecipes if we have tags (required for the arrayContainsAny query provided)
    // Otherwise fall back to getting all recipes for the user
    if (filters.tags && filters.tags.length > 0) {
        return await searchRecipes(user.uid, filters.minRating || 0, filters.tags);
    } else {
        return await getRecipesForUser(user.uid);
    }
}


export default function RecipesPage() {
    return <Recipes />;
}
