import React, { useState } from "react";
import { useLoaderData, useNavigate } from "react-router";
import Markdown from "react-markdown";
import { Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import type { Recipe } from "../firebase/data";
import { deleteRecipe, updateRecipeRating } from "../firebase/data";

const Layout: React.FC = () => {
    const recipe = useLoaderData<Recipe>();
    const navigate = useNavigate();
    const [rating, setRating] = useState(recipe?.averageRating || 0);

    const handleRating = async (newRating: number) => {
        setRating(newRating);
        if (recipe) {
            await updateRecipeRating(recipe.authorId, recipe.id, newRating);
        }
    };

    const handleDelete = async () => {
        if (confirm("Are you sure you want to delete this recipe?")) {
            await deleteRecipe(recipe!.authorId, recipe!.id);
            navigate("/recipes");
        }
    };

    if (!recipe) {
        return (
            <div className="flex items-center justify-center p-8">
                <h2 className="text-xl font-semibold">Recipe not found</h2>
            </div>
        );
    }

    return (
        <div className="container mx-auto max-w-4xl py-6">
            <Card>
                {recipe.imageUri && (
                    <div className="relative w-full h-64 overflow-hidden rounded-t-xl bg-muted">
                        <img
                            src={recipe.imageUri}
                            alt={recipe.title}
                            className="w-full h-full object-cover"
                        />
                    </div>
                )}
                <CardHeader>
                    <div className="flex flex-col gap-2">
                        <div className="flex justify-between items-start">
                            <CardTitle className="text-3xl">{recipe.title}</CardTitle>
                            <div className="flex items-center gap-1">
                                {[1, 2, 3, 4, 5].map((star) => (
                                    <Star
                                        key={star}
                                        className={`w-5 h-5 cursor-pointer transition-colors ${star <= rating
                                                ? "fill-yellow-500 text-yellow-500"
                                                : "text-muted-foreground/30 hover:text-yellow-500"
                                            }`}
                                        onClick={() => handleRating(star)}
                                    />
                                ))}
                            </div>
                        </div>

                        <div className="flex flex-wrap gap-2 mt-2">
                            {recipe.tags.map((tag) => (
                                <span
                                    key={tag}
                                    className="px-2 py-1 text-xs font-semibold rounded-full bg-primary/10 text-primary"
                                >
                                    {tag}
                                </span>
                            ))}
                        </div>

                        <CardDescription className="flex flex-wrap gap-4 mt-2 text-sm text-muted-foreground">
                            {recipe.prepTime !== "Unknown" && (
                                <div className="flex items-center gap-1">
                                    <span className="font-semibold">Prep:</span> {recipe.prepTime}
                                </div>
                            )}
                            {recipe.cookTime !== "Unknown" && (
                                <div className="flex items-center gap-1">
                                    <span className="font-semibold">Cook:</span> {recipe.cookTime}
                                </div>
                            )}
                            {recipe.servings !== "Unknown" && (
                                <div className="flex items-center gap-1">
                                    <span className="font-semibold">Servings:</span> {recipe.servings}
                                </div>
                            )}
                            <div className="flex items-center gap-1">
                                <span className="font-semibold">Saves:</span> {recipe.saves}
                            </div>
                        </CardDescription>
                    </div>
                </CardHeader>

                <Separator />

                <CardContent className="grid gap-6 md:grid-cols-[1fr_2fr] pt-6">
                    <div>
                        <h3 className="text-lg font-semibold mb-3">Ingredients</h3>
                        <ul className="list-disc list-inside space-y-1 text-sm text-muted-foreground">
                            {recipe.ingredients.map((ingredient, index) => (
                                <li key={index}>{ingredient}</li>
                            ))}
                        </ul>
                    </div>

                    <div>
                        <h3 className="text-lg font-semibold mb-3">Instructions</h3>
                        <div className="prose prose-sm text-muted-foreground dark:prose-invert">
                            <Markdown>{recipe.instructions}</Markdown>
                        </div>
                    </div>
                </CardContent>
            </Card>
            <div className="flex justify-end mt-6">
                <Button variant="destructive" onClick={handleDelete}>
                    Delete Recipe
                </Button>
            </div>
        </div >
    );
};

export default Layout;