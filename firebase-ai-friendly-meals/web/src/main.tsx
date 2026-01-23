import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import ImageLayout from "./components/ImageLayout"
import TextLayout from "./components/TextLayout"
import ChatLayout from "./components/ChatLayout"
import Layout from './components/Layout.tsx'
import { createBrowserRouter, RouterProvider } from "react-router";
import Home from "./components/Home";
import Recipes from "./components/Recipes";
import Recipe from "./components/Recipe";
import { getRecipe, searchRecipes, getRecipesForUser } from './firebase/data.ts'
import { getUser } from "@/firebase/auth";

const router = createBrowserRouter([
  {
    path: "/",
    Component: Home,
    index: true,
  },
  {
    Component: Layout,
    children: [
      {
        path: "chat",
        Component: ChatLayout,
      },
      {
        path: "generate",
        Component: TextLayout,
      },
      {
        path: "image",
        Component: ImageLayout,
      },
      {
        path: "recipes",

        children: [
          {
            index: true,
            Component: Recipes,
            hydrateFallbackElement: <p>Loading...</p>,
            loader: async ({ request }) => {
              const user = await getUser();
              const url = new URL(request.url);
              const filters = {
                name: url.searchParams.get('q') || undefined,
                minRating: url.searchParams.get('minRating') ? Number(url.searchParams.get('minRating')) : undefined,
                tags: url.searchParams.get('tags') ? url.searchParams.get('tags')!.split(',') : undefined,
                sortBy: (url.searchParams.get('sort') as 'rating' | 'title') || undefined,
              };

              // Use searchRecipes if we have tags (required for the arrayContainsAny query provided)
              // Otherwise fall back to getting all recipes for the user
              if (filters.tags && filters.tags.length > 0) {
                return await searchRecipes(user.uid, filters.minRating || 0, filters.tags);
              } else {
                return await getRecipesForUser(user.uid);
              }
            },
          },
          {
            path: ":recipeId",
            Component: Recipe,
            hydrateFallbackElement: <p>Loading...</p>,
            loader: async ({ params }) => {
              if (!params.recipeId) {
                throw new Error("No recipe ID provided");
              }
              console.log('recipe loader is running')
              await getUser(); // ensure auth
              const recipe = await getRecipe(params.recipeId);
              return recipe;
            },
          },
        ],
      },
    ],
  },
]);

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>,
)
