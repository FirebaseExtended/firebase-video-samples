import React from "react";
import Markdown from "react-markdown";
import { Button } from "@/components/ui/button";
import { saveRecipe, type Recipe } from "../firebase/data";
import { getUser } from "../firebase/auth";

interface Ingredient {
  title: string;
  unit: string;
  amount: number;
}

interface Instruction {
  description: string;
}

export interface StructuredJsonRecipe {
  ingredients: Ingredient[];
  instructions: Instruction[];
}

interface GeneratedRecipeProp {
  data: GeneratedRecipeData;
}

export interface GeneratedRecipeData {
  textRecipe?: string;
  errorMessage?: string;
  structuredRecipe?: StructuredJsonRecipe;
}

const GeneratedRecipe: React.FC<GeneratedRecipeProp> = ({
  data,
}: GeneratedRecipeProp) => {
  const handleSave = async () => {
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

      if (data.textRecipe) {
        recipeToSave = {
          ...baseRecipe,
          instructions: data.textRecipe,
          ingredients: []
        };
      } else if (data.structuredRecipe) {
        recipeToSave = {
          ...baseRecipe,
          instructions: data.structuredRecipe.instructions.map(i => i.description).join('\n'),
          ingredients: data.structuredRecipe.ingredients.map(i => `${i.amount} ${i.unit} ${i.title}`)
        };
      }
      if (recipeToSave) {
        await saveRecipe(user.uid, recipeToSave);
        alert("Recipe saved!");
      }
    }
  };

  if (data.textRecipe)
    return (
      <div className="flex flex-col items-start gap-4">
        <div className="prose prose-slate">
          <Markdown>{data.textRecipe}</Markdown>
        </div>
        <Button onClick={handleSave}>Save Recipe</Button>
      </div>
    );
  if (data.errorMessage) return <div>{data.errorMessage}</div>;


  if (data.structuredRecipe) {

    return (
      <div className="flex flex-col items-start gap-4">
        <div className="prose prose-slate">
          <h3>Ingredients</h3>
          <ul>
            {data.structuredRecipe.ingredients.map((ingredient, index) => (
              <li key={index}>
                {ingredient.title} {ingredient.amount} {ingredient.unit}
              </li>
            ))}
          </ul>
          <h3>Instructions</h3>
          <ol>
            {data.structuredRecipe.instructions.map((instruction, index) => (
              <li key={index}>{instruction.description}</li>
            ))}
          </ol>
        </div>
        <Button onClick={handleSave}>Save Recipe</Button>
      </div>
    );
  }

  return <div>A recipe will be displayed here when one is generated.</div>;
};

export default GeneratedRecipe;

