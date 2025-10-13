import React, { useState } from "react";
import styles from "../styles/IngredientInput.module.css";

interface IngredientInputProps {
  handleSubmit: (ingredients: string, cuisineType: string) => Promise<void>;
  isLoading: boolean;
}

export const IngredientInput: React.FC<IngredientInputProps> = ({ handleSubmit, isLoading }) => {
  const [ingredients, setIngredients] = useState("");
  const [cuisineType, setCuisineType] = useState("");

  return (
    <div className={styles.ingredientInputContainer}>
      <div>
        <label className={styles.label}>Ingredients</label>
        <textarea
          className={styles.ingredientTextArea}
          disabled={isLoading}
          placeholder="Enter your list of ingredients"
          onChange={(e) => setIngredients(e.target.value)}
          rows={5}
        />
      </div>
      <div className={styles.cuisineTypeDropdownContainer}>
        <select
          className={styles.cuisineTypeDropdown}
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
        onClick={() => handleSubmit(ingredients, cuisineType)}>{isLoading ? 'Loading' : 'Generate'}
      </button>
    </div>
  );
}
