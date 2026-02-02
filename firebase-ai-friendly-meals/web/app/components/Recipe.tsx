import React, { useState } from "react";
import { useNavigate } from "react-router";
import Markdown from "react-markdown";
import {
    Star,
    Clock,
    Flame,
    Users,
    Heart
} from "lucide-react";
import { Button } from "@/components/ui/button";
import type { Recipe } from "../firebase/data";
import { deleteRecipe, addReview, likeRecipe, unlikeRecipe } from "../firebase/data";
import { getUser } from "../firebase/auth";

const InfoBox = ({ icon: Icon, label, value }: { icon: any, label: string, value: string | number }) => (
    <div className="flex flex-col items-center justify-center p-3 py-4 bg-muted/40 rounded-2xl gap-2 flex-1 min-w-[30%]">
        <div className="p-2 bg-background rounded-full shadow-sm text-emerald-600">
            <Icon className="w-5 h-5" />
        </div>
        <span className="text-[10px] text-muted-foreground font-bold uppercase tracking-wider">{label}</span>
        <span className="font-semibold text-sm text-center">{value}</span>
    </div>
);

interface RecipeDetailProps {
    recipe: Recipe;
    readonly?: boolean;
    liked?: boolean;
}

const RecipeDetail: React.FC<RecipeDetailProps> = ({ recipe, readonly = false, liked = false }) => {
    const navigate = useNavigate();
    const [rating, setRating] = useState(recipe.averageRating);
    const [isLiked, setIsLiked] = useState(liked);

    const handleLikeToggle = async () => {
        setIsLiked(!isLiked);
        const user = await getUser();
        if (isLiked) {
            await unlikeRecipe(user.uid, recipe.id);
        } else {
            await likeRecipe(user.uid, recipe.id);
        }
    };

    const handleRating = async (newRating: number) => {
        if (recipe) {
            const user = await getUser();
            await addReview(recipe.id, user.uid, newRating);
        }
        setRating(newRating);
    };

    const handleDelete = async () => {
        if (confirm("Are you sure you want to delete this recipe?")) {
            await deleteRecipe(recipe!.id);
            navigate("/recipes");
        }
    };

    if (!recipe) {
        return (
            <div className="flex items-center justify-center h-screen">
                <h2 className="text-xl font-semibold">Recipe not found</h2>
            </div>
        );
    }

    return (
        <div className="flex items-center flex-col gap-8">
            <div className="bg-background min-h-screen relative max-w-2xl mx-auto shadow-sm border rounded-xl overflow-hidden">
                {/* Top Image Section */}
                <div className="relative w-full aspect-[4/3] md:aspect-video bg-muted">
                    {recipe.imageUri ? (
                        <img
                            src={recipe.imageUri}
                            alt={recipe.title}
                            className="w-full h-full object-cover"
                        />
                    ) : (
                        <div className="w-full h-full flex items-center justify-center bg-emerald-50 text-emerald-200">
                            <Flame className="w-20 h-20" />
                        </div>
                    )}

                    {/* FAB Heart */}
                    {!readonly && (
                        <div className="absolute -bottom-6 right-6 z-20">
                            <Button
                                size="icon"
                                className={`rounded-full w-14 h-14 shadow-xl border-4 border-background transition-colors ${isLiked ? "bg-red-500 hover:bg-red-600" : "bg-emerald-500 hover:bg-emerald-600"
                                    } text-white`}
                                onClick={handleLikeToggle}
                            >
                                <Heart className={`w-7 h-7 ${isLiked ? "fill-current" : ""}`} />
                            </Button>
                        </div>
                    )}
                </div>

                {/* Content Container */}
                <div className="px-6 pt-10 pb-6 space-y-8">
                    {/* Title & Rating */}
                    <div className="space-y-2">
                        <h1 className="text-2xl md:text-3xl font-bold leading-tight text-foreground">
                            {recipe.title}
                        </h1>
                        <div className="flex items-center gap-1">
                            {[1, 2, 3, 4, 5].map((star) => (
                                <Star
                                    key={star}
                                    className={`w-5 h-5 transition-all ${star <= rating
                                        ? "fill-amber-400 text-amber-400"
                                        : "text-muted-foreground/20"
                                        } ${!readonly ? "cursor-pointer hover:text-amber-400" : ""}`}
                                    onClick={() => handleRating(star)}
                                />
                            ))}
                            <span className="ml-2 text-sm text-muted-foreground font-medium">
                                {rating > 0 ? rating.toFixed(1) : 'No ratings'}
                            </span>
                        </div>
                    </div>

                    {/* Metadata Grid */}
                    <div className="flex gap-4 justify-between">
                        <InfoBox icon={Clock} label="Prep Time" value={recipe.prepTime} />
                        <InfoBox icon={Flame} label="Cook Time" value={recipe.cookTime} />
                        <InfoBox icon={Users} label="Servings" value={recipe.servings} />
                    </div>

                    {/* Ingredients */}
                    <div className="space-y-4">
                        <h2 className="text-lg font-bold text-emerald-700 dark:text-emerald-400 uppercase tracking-wide">
                            Ingredients
                        </h2>
                        <div className="space-y-3 bg-muted/20 p-6 rounded-3xl border border-border/50">
                            {recipe.ingredients.map((ingredient, index) => (
                                <div key={index} className="flex items-start gap-3">
                                    <div className="mt-1 w-5 h-5 min-w-5 rounded-full border-2 border-muted-foreground/30 flex-shrink-0" />
                                    <span className="text-foreground/90 leading-relaxed font-medium">
                                        {ingredient}
                                    </span>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Instructions */}
                    <div className="space-y-4">
                        <h2 className="text-lg font-bold text-emerald-700 dark:text-emerald-400 uppercase tracking-wide">
                            Instructions
                        </h2>
                        <div className="p-6 rounded-3xl border border-border/50 bg-card prose prose-stone dark:prose-invert max-w-none prose-headings:text-foreground prose-p:text-foreground/90 prose-li:text-foreground/90">
                            <Markdown>{recipe.instructions}</Markdown>
                        </div>
                    </div>


                </div>

            </div>
            {!readonly && (
                <Button
                    variant="ghost"
                    className="text-muted-foreground hover:text-destructive hover:bg-destructive/5"
                    onClick={handleDelete}
                >
                    Delete This Recipe
                </Button>
            )}
        </div>
    );
};

export default RecipeDetail;