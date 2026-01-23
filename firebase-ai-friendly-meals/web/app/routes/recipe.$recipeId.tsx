import type { Route } from "./+types/recipe.$recipeId";
import Recipe from "../components/Recipe";
import { getRecipe } from "../firebase/data";
import { getUser } from "../firebase/auth";

export function meta({ data }: Route.MetaArgs) {
    const title = data?.title || "Recipe";
    return [
        { title: `${title} - Friendly Meals` },
        { name: "description", content: `View recipe: ${title}` },
    ];
}

export async function clientLoader({ params }: Route.ClientLoaderArgs) {
    if (!params.recipeId) {
        throw new Error("No recipe ID provided");
    }
    console.log('recipe loader is running');
    await getUser(); // ensure auth
    const recipe = await getRecipe(params.recipeId);
    return recipe;
}


export default function RecipePage() {
    return <Recipe />;
}
