import React from "react";
import Markdown from "react-markdown";

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
  if (data.textRecipe)
    return (
      <div>
        <Markdown>{data.textRecipe}</Markdown>
      </div>
    );
  if (data.errorMessage) return <div>{data.errorMessage}</div>;

  console.log("hello");
  if (data.structuredRecipe) {
    console.log("structured");
    return (
      <div>
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
    );
  }
  console.log("not structured");
  return <div>A recipe will be displayed here when one is generated.</div>;
};

export default GeneratedRecipe;

