import React, { useState } from "react";
import { generateRecipeFromImage } from "../firebase/firebaseAILogic";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Field, FieldLabel } from "@/components/ui/field";
import { Spinner } from "@/components/ui/spinner";
import type { Recipe } from "../firebase/data";
import { saveRecipe } from "../firebase/data";
import RecipeDetail from "./Recipe";
import { ChevronDown, ChevronUp, Sparkles } from "lucide-react";
import { getUser } from "../firebase/auth";
import { useNavigate } from "react-router";

const Layout: React.FC = () => {
  const [cuisineType, setCuisineType] = useState("");
  const [image, setImage] = useState<File>(new File([], '', { type: "image", }));
  const [isLoading, setIsLoading] = useState(false);
  const [generatedRecipe, setGeneratedRecipe] = useState<Recipe | null>(null);
  const [isInputExpanded, setIsInputExpanded] = useState(true);
  const navigate = useNavigate();

  const generateRecipeFromImageHandler = async (
    image: File,
    cuisineType: string
  ) => {
    setIsLoading(true);
    try {
      const recipe = await generateRecipeFromImage(image, cuisineType);
      setGeneratedRecipe(recipe);
      setIsInputExpanded(false);
    } catch (error) {
      console.error("Error generating text recipe:", error);
      // Handle error
    } finally {
      setIsLoading(false);
    }
  }

  const handleSave = async () => {
    if (!generatedRecipe) return;
    const user = await getUser();
    if (user) {
      const recipeToSave = {
        ...generatedRecipe,
        authorId: user.uid,
        averageRating: 0,
        saves: 0,
        tags: generatedRecipe.tags || []
      };
      const savedRecipeId = await saveRecipe(user.uid, recipeToSave);
      navigate(`/recipes/${savedRecipeId}`);
    }
  };

  return (
    <div className="flex flex-col gap-6 max-w-4xl mx-auto p-4">
      {/* Input Section */}
      <div className="bg-card border rounded-xl overflow-hidden shadow-sm">
        <button
          onClick={() => setIsInputExpanded(!isInputExpanded)}
          className="w-full flex items-center justify-between p-4 hover:bg-muted/50 transition-colors"
        >
          <div className="flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-emerald-600" />
            <span className="font-medium">Scan Recipe from Image</span>
          </div>
          {isInputExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
        </button>

        {isInputExpanded && (
          <div className="p-4 border-t bg-muted/10 space-y-4">
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
          </div>
        )}
      </div>

      {/* Result Section */}
      {generatedRecipe && (
        <div className="animate-in fade-in slide-in-from-bottom-4 duration-500">

          <RecipeDetail recipeData={generatedRecipe} readonly={true} />
          <div className="flex justify-center mt-8 pb-12">
            <Button onClick={handleSave} size="lg" className="shadow-lg bg-emerald-600 hover:bg-emerald-700 min-w-[200px]">
              Save to My Recipes
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};

export default Layout;