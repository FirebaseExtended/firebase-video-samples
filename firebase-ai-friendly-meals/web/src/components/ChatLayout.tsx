import React, { useState } from "react";
import styles from "../styles/Layout.module.css";
import { IngredientInput } from "./IngredientInput";
import GeneratedRecipe, { type GeneratedRecipeData } from "./GeneratedRecipe";
import { generateStructuredJsonRecipe, generateTextRecipe } from "../firebase/firebaseAILogic";

const Layout: React.FC = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [generatedRecipe, setGeneratedRecipe] = useState<GeneratedRecipeData>({});

  const generateTextRecipeHandler = async (
    ingredients: string,
    cuisineType: string
  ) => {
    setIsLoading(true);

    try {
      // For text recipes, uncomment below
      const generatedRecipe = await generateTextRecipe(
        ingredients,
        cuisineType
      );
      setGeneratedRecipe({
        textRecipe: generatedRecipe
      });

    } catch (error) {
      console.error("Error generating text recipe:", error);
      setGeneratedRecipe({
        errorMessage:
          "An error occured while generating the recipe. See browser console logs for more details.",
      });
      setIsLoading(false);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className={styles.mainContainer}>
      <h1>Friendly Meals</h1>
      <div className={styles.contentContainer}>
        <div className={[styles.layoutPane, styles.input].join(' ')}>
          <IngredientInput
            isLoading={isLoading}
            handleSubmit={generateTextRecipeHandler}
          />
        </div>
        <div className={[styles.layoutPane, styles.output].join(' ')}>
          <GeneratedRecipe data={generatedRecipe} />
        </div>
      </div>
    </div>
  );
};

export default Layout;