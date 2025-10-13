import React, { useState } from "react";
import styles from "../styles/Layout.module.css";
import ImageLayoutStyles from "../styles/ImageLayout.module.css";
import GeneratedRecipe, { type GeneratedRecipeData } from "./GeneratedRecipe";
import { generateTextRecipeWithImage } from "../firebase/firebaseAILogic";

const Layout: React.FC = () => {
  const [cuisineType, setCuisineType] = useState("");
  const [image, setImage] = useState<File>(new File([], '', { type: "image", }));
  const [isLoading, setIsLoading] = useState(false);
  const [generatedRecipe, setGeneratedRecipe] = useState<GeneratedRecipeData>({});

  const generateRecipeFromImageHandler = async (
    image: File,
    cuisineType: string
  ) => {
    setIsLoading(true);

    try {
      const generatedRecipe = await generateTextRecipeWithImage(image, cuisineType);
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

  }
  
  return (
    <div className={styles.mainContainer}>
      <h1>Friendly Meals</h1>
      <div className={styles.contentContainer}>
          <div className={ImageLayoutStyles.ingredientInputContainer}>
            <label className={ImageLayoutStyles.label}>Ingredients</label>
            <div className={ImageLayoutStyles.imageInputContainer}>
              <input type="file" id="img" disabled={isLoading}
                     onChange={e => setImage(e.currentTarget.files ? e.currentTarget.files[0] : image)} />
            </div>
            <div className={ImageLayoutStyles.cuisineTypeDropdownContainer}>
              <select
                className={ImageLayoutStyles.cuisineTypeDropdown}
                disabled={isLoading}
                value={cuisineType}
                onChange={(e) => setCuisineType(e.target.value)}
              >
                <option value="">Cuisine type</option>
                <option value="Italian">Italian</option>
                <option value="Mexican">Mexican</option>
                <option value="Asian">Asian</option>
                <option value="American">American</option>
              </select>
            </div>
            <button 
              disabled={isLoading}
              onClick={() => generateRecipeFromImageHandler(image, cuisineType)}>{isLoading ? 'Loading' : 'Generate'}
            </button>
          </div>
        <div className={styles.layoutPane}>
          <GeneratedRecipe data={generatedRecipe} />
        </div>
      </div>
    </div>
  );
};

export default Layout;