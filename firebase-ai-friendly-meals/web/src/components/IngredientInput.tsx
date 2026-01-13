import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Field, FieldLabel } from "@/components/ui/field";
import { Spinner } from "@/components/ui/spinner";

interface IngredientInputProps {
  handleSubmit: (ingredients: string, cuisineType: string) => Promise<void>;
  isLoading: boolean;
}

export const IngredientInput: React.FC<IngredientInputProps> = ({ handleSubmit, isLoading }) => {
  const [ingredients, setIngredients] = useState("");
  const [cuisineType, setCuisineType] = useState("");

  const inputClasses = "flex w-full rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 md:text-sm";

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      handleSubmit(ingredients, cuisineType)
    }} className="space-y-4">
      <Field>
        <FieldLabel>Ingredients</FieldLabel>
        <textarea
          className={`${inputClasses} min-h-[120px] py-3`}
          disabled={isLoading}
          placeholder="Enter your list of ingredients"
          onChange={(e) => setIngredients(e.target.value)}
          rows={5}
        />
      </Field>
      <Field>
        <FieldLabel>Cuisine</FieldLabel>
        <div className="relative">
          <select
            className={`${inputClasses} h-9 appearance-none`}
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
          <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
            <svg className="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" /></svg>
          </div>
        </div>
      </Field>
      <Button
        className="w-full"
        disabled={isLoading}
        type="submit">
        {isLoading && <Spinner className="mr-2 h-4 w-4" />}
        {isLoading ? 'Loading...' : 'Generate'}
      </Button>
    </form>
  );
}
