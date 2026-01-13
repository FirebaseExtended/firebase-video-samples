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
import { getRecipes, getRecipe } from './firebase/data.ts'
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
            loader: async () => {
              const user = await getUser();

              const recipes = await getRecipes(user.uid);
              return recipes;
            },
          },
          {
            path: ":recipeId",
            Component: Recipe,
            loader: async ({ params }) => {
              console.log('recipe loader is running')
              const user = await getUser();
              const recipe = await getRecipe(user.uid, params.recipeId);
              console.log(recipe)
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
