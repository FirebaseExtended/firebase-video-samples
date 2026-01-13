import React from "react";
import {
    Empty,
    EmptyHeader,
    EmptyTitle,
    EmptyDescription,
    EmptyContent,
    EmptyMedia
} from "@/components/ui/empty";
import { Button } from "@/components/ui/button";
import { useLoaderData } from "react-router";
import type { Recipe } from "../firebase/data";

const ZeroState: React.FC = () => {
    return (
        <div className="flex h-full flex-1 flex-col gap-4 p-4 md:gap-8 md:p-10">
            <Empty>
                <EmptyMedia variant="icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="lucide lucide-book-open"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" /><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" /></svg>
                </EmptyMedia>
                <EmptyHeader>
                    <EmptyTitle>No recipes yet</EmptyTitle>
                    <EmptyDescription>
                        Generate recipes to start building your collection.
                    </EmptyDescription>
                </EmptyHeader>
                <EmptyContent>
                    <Button asChild>
                        <a href="/generate">Generate Recipe</a>
                    </Button>
                </EmptyContent>
            </Empty>
        </div>
    );
}

const Layout: React.FC = () => {
    const recipes = useLoaderData<Array<Recipe>>();
    if (!recipes) {
        return <ZeroState />;
    }


    return (
        <ul>
            {recipes.map(recipe => (
                <li key={recipe.id}><a href={`/recipes/${recipe.id}`}>{recipe.title}</a></li>
            ))}
        </ul>
    );
};

export default Layout;