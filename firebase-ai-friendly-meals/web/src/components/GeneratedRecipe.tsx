import React from "react";
import Markdown from "react-markdown";
import { Button } from "@/components/ui/button";
import { saveRecipe, type Recipe } from "../firebase/data";
import { getUser } from "../firebase/auth";
import { useNavigate } from "react-router";

interface Ingredient {
  title: string;
  unit: string;
  amount: number;
}

interface Instruction {
  description: string;
}

interface GeneratedRecipeProp {
  data: GeneratedRecipeData;
}

export interface GeneratedRecipeData {
  errorMessage?: string;
  structuredRecipe?: Recipe;
}

const GeneratedRecipe: React.FC<GeneratedRecipeProp> = ({
  data,
}: GeneratedRecipeProp) => {
  console.log(JSON.stringify(data, null, 2));
  const navigate = useNavigate();
  const handleSave = async () => {
    if (!data.structuredRecipe) {
      return;
    }
    const user = await getUser();
    if (user) {
      // If we are in the text recipe view (checked first), save text.
      // If we are in structured, save structured.
      // However, since we return early, we can determine what to save based on data structure again or context.
      // Simplest is to save what we have.
      let recipeToSave: Omit<Recipe, "id"> | null = null;

      const baseRecipe = {
        title: "AI Generated Recipe",
        authorId: user.uid,
        tags: [],
        averageRating: 0,
        saves: 0,
        prepTime: "Unknown",
        cookTime: "Unknown",
        servings: "Unknown",
        // Default to empty string if no image provided
        imageUri: ""
      };

      recipeToSave = {
        ...baseRecipe,
        ...(data.structuredRecipe)
      };

      const savedRecipeId = await saveRecipe(user.uid, recipeToSave);
      navigate(`/recipes/${savedRecipeId}`);
    }
  };

  if (data.errorMessage) return <div>{data.errorMessage}</div>;

  if (data.structuredRecipe) {
    return (
      <div className="flex flex-col items-start gap-4">
        <div className="prose prose-slate">
          <h2>{data.structuredRecipe.title}</h2>
          <ul>
            <li>Prep Time: {data.structuredRecipe.prepTime} minutes</li>
            <li>Cook Time: {data.structuredRecipe.cookTime} minutes</li>
            <li>Serves: {data.structuredRecipe.servings}</li>
          </ul>
          <h3>Ingredients</h3>
          <ul>
            {data.structuredRecipe.ingredients.map((ingredient, index) => (
              <li key={index}>
                {ingredient}
              </li>
            ))}
          </ul>
          <h3>Instructions</h3>
          <ol>
            {data.structuredRecipe.instructions}
          </ol>
        </div>
        <Button onClick={handleSave}>Save Recipe</Button>
      </div>
    );
  }

  return <div>A recipe will be displayed here when one is generated.</div>;
};

export default GeneratedRecipe;

