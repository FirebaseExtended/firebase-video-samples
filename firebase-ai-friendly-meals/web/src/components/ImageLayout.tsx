import React, { useState } from "react";

import GeneratedRecipe, { type GeneratedRecipeData } from "./GeneratedRecipe";
import { generateTextRecipeWithImage } from "../firebase/firebaseAILogic";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
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