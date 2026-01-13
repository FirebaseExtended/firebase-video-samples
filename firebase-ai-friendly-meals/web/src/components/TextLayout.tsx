
import React, { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { IngredientInput } from "./IngredientInput";
import GeneratedRecipe, { type GeneratedRecipeData } from "./GeneratedRecipe";
import { generateStructuredJsonRecipe } from "../firebase/firebaseAILogic";
import type { Recipe } from "../firebase/data";

const Layout: React.FC = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [generatedRecipe, setGeneratedRecipe] = useState<GeneratedRecipeData>({});

  const generateTextRecipeHandler = async (
    ingredients: string,
    cuisineType: string
  ) => {
    try {
      setIsLoading(true);
      const generatedRecipe: Recipe = await generateStructuredJsonRecipe(
        ingredients,
        cuisineType
      );
      setGeneratedRecipe({
        structuredRecipe: generatedRecipe
      });
    } catch (error) {
      console.error("Error generating text recipe:", error);
      setGeneratedRecipe({
        errorMessage:
          "An error occured while generating the recipe. See browser console logs for more details.",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="grid gap-4 md:grid-cols-2">
      <Card className="h-full flex flex-col">
        <CardHeader>
          <CardTitle>Input</CardTitle>
        </CardHeader>
        <CardContent className="flex-1">
          <IngredientInput
            isLoading={isLoading}
            handleSubmit={generateTextRecipeHandler}
          />
        </CardContent>
      </Card>
      <Card className="h-full flex flex-col">
        <CardHeader>
          <CardTitle>Result</CardTitle>
        </CardHeader>
        <CardContent className="flex-1 overflow-auto">
          <GeneratedRecipe data={generatedRecipe} />
        </CardContent>
      </Card>
    </div>
  );
};

export default Layout;