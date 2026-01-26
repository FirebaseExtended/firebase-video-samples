import type { Route } from "./+types/generate";

import { useState } from "react";
import { IngredientInput } from "@/components/IngredientInput";
import { generateStructuredJsonRecipe } from "@/firebase/firebaseAILogic";
import type { Recipe } from "@/firebase/data";
import { publishRecipe } from "@/firebase/data";
import RecipeDetail from "@/components/Recipe";
import { Button } from "@/components/ui/button";
import { ChevronDown, ChevronUp, Sparkles } from "lucide-react";
import { getUser } from "@/firebase/auth";
import { useNavigate } from "react-router";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Generate Recipe - Friendly Meals" },
        { name: "description", content: "Generate a new recipe with AI" },
    ];
}

export default function GeneratePage() {
    const [isLoading, setIsLoading] = useState(false);
    const [generatedRecipe, setGeneratedRecipe] = useState<Recipe | null>(null);
    const [isInputExpanded, setIsInputExpanded] = useState(true);
    const navigate = useNavigate();

    const generateTextRecipeHandler = async (
        ingredients: string,
        cuisineType: string
    ) => {
        try {
            setIsLoading(true);
            const recipe: Recipe = await generateStructuredJsonRecipe(
                ingredients,
                cuisineType
            );
            setGeneratedRecipe(recipe);
        } catch (error) {
            console.error("Error generating text recipe:", error);
        } finally {
            setIsLoading(false);
        }
    };

    const handleSave = async () => {
        if (!generatedRecipe) return;
        const user = await getUser();
        if (user) {
            const recipeToSave = {
                ...generatedRecipe,
                authorId: user.uid,
                averageRating: 0,
                saves: 0,
                tags: generatedRecipe.tags || []
            };
            const savedRecipeId = await publishRecipe(user.uid, recipeToSave);
            navigate(`/recipes/${savedRecipeId}`);
        }
    };

    return (
        <div className="flex flex-col gap-6 max-w-4xl mx-auto p-4">
            <div className="bg-card border rounded-xl overflow-hidden shadow-sm">
                <button
                    onClick={() => setIsInputExpanded(!isInputExpanded)}
                    className="w-full flex items-center justify-between p-4 hover:bg-muted/50 transition-colors"
                >
                    <div className="flex items-center gap-2">
                        <Sparkles className="w-4 h-4 text-emerald-600" />
                        <span className="font-medium">Generate New Recipe</span>
                    </div>
                    {isInputExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                </button>

                {isInputExpanded && (
                    <div className="p-4 border-t bg-muted/10">
                        <IngredientInput
                            isLoading={isLoading}
                            handleSubmit={generateTextRecipeHandler}
                        />
                    </div>
                )}
            </div>

            {generatedRecipe && (
                <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">
                    <p>Here is your generated recipe. Click the Publish button at the bottom to share with others.</p>
                    <RecipeDetail recipe={generatedRecipe} readonly={true} />
                    <div className="flex justify-center mt-8 pb-12">
                        <Button onClick={handleSave} size="lg" className="shadow-lg bg-emerald-600 hover:bg-emerald-700 min-w-[200px] cursor-pointer">
                            Publish
                        </Button>
                    </div>
                </div>
            )}
        </div>
    );
}
