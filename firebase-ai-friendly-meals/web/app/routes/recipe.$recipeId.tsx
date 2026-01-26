import type { Route } from "./+types/recipe.$recipeId";
import Recipe from "../components/Recipe";
import { getLike, getRecipe } from "../firebase/data";
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
    await getUser(); // ensure auth
    const recipe = await getRecipe(params.recipeId);
    const isLiked = await getLike(params.recipeId);
    return { recipe, isLiked };
}

export default function RecipePage({ loaderData }: Route.ComponentProps) {
    return <Recipe recipe={loaderData.recipe} liked={loaderData.isLiked} />;
}
