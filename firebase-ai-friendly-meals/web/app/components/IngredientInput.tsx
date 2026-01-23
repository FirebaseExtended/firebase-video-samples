import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Field, FieldLabel } from "@/components/ui/field";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { Spinner } from "@/components/ui/spinner";

interface IngredientInputProps {
  handleSubmit: (ingredients: string, cuisineType: string) => Promise<void>;
  isLoading: boolean;
}

export const IngredientInput: React.FC<IngredientInputProps> = ({ handleSubmit, isLoading }) => {
  const [ingredients, setIngredients] = useState("");
  const [cuisineType, setCuisineType] = useState("");

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      handleSubmit(ingredients, cuisineType)
    }} className="space-y-4">
      <Field>
        <FieldLabel>Ingredients</FieldLabel>
        <Textarea
          disabled={isLoading}
          placeholder="Enter your list of ingredients"
          onChange={(e) => setIngredients(e.target.value)}
          rows={5}
        />
      </Field>
      <Field>
        <FieldLabel>Cuisine</FieldLabel>
        <Select
          disabled={isLoading}
          value={cuisineType}
          onChange={(e) => setCuisineType(e.target.value)}
        >
          <option value="">Cuisine type</option>
          <option value="Italian">Italian</option>
          <option value="Mexican">Mexican</option>
          <option value="Asian">Asian</option>
          <option value="American">American</option>
        </Select>
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
