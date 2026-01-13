import React, { useState } from "react";

import GeneratedRecipe, { type GeneratedRecipeData } from "./GeneratedRecipe";
import { generateTextRecipeWithImage } from "../firebase/firebaseAILogic";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Field, FieldLabel } from "@/components/ui/field";
import { Spinner } from "@/components/ui/spinner";

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

  const inputClasses = "flex w-full rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 md:text-sm";

  return (
    <div className="grid gap-4 md:grid-cols-2">
      <Card className="h-full flex flex-col">
        <CardHeader>
          <CardTitle>Scan Recipe</CardTitle>
        </CardHeader>
        <CardContent className="flex-1 space-y-4">
          <Field>
            <FieldLabel>Image</FieldLabel>
            <Input
              type="file"
              id="img"
              disabled={isLoading}
              onChange={e => setImage(e.currentTarget.files ? e.currentTarget.files[0] : image)}
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
            onClick={() => generateRecipeFromImageHandler(image, cuisineType)}>
            {isLoading && <Spinner className="mr-2 h-4 w-4" />}
            {isLoading ? 'Loading...' : 'Generate'}
          </Button>
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