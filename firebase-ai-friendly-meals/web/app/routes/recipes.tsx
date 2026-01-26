import type { Route } from "./+types/recipes";
import { queryRecipes, getTop5Tags } from "@/firebase/data";
import { getUser } from "@/firebase/auth";

import React, { useState, useEffect, useRef } from "react";
import {
    Empty,
    EmptyHeader,
    EmptyTitle,
    EmptyDescription,
    EmptyContent,
    EmptyMedia
} from "@/components/ui/empty";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Field, FieldLabel, FieldGroup } from "@/components/ui/field";
import { Link, useSearchParams, useNavigate, Form } from "react-router";
import type { Recipe } from "../firebase/data";
import {
    Item,
    ItemContent,
    ItemDescription,
    ItemGroup,
    ItemActions,
    ItemTitle,
} from "@/components/ui/item"
import { Star, ChevronDown, ChevronUp, Search, X } from "lucide-react";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "All Recipes - Friendly Meals" },
        { name: "description", content: "Browse all recipes" },
    ];
}

export async function clientLoader({ request }: Route.ClientLoaderArgs) {
    const user = await getUser();
    const url = new URL(request.url);

    const filters = {
        searchTerm: url.searchParams.get('q') || undefined,
        minRating: url.searchParams.get('minRating') ? Number(url.searchParams.get('minRating')) : undefined,
        tags: url.searchParams.get('tags') ? url.searchParams.get('tags')!.split(',') : undefined,
        authorId: url.searchParams.get('myRecipes') === 'on' ? user.uid : undefined,
        likedOnly: url.searchParams.get('likedOnly') === 'on',
        sort: url.searchParams.get('sort') || undefined
    };

    const [recipes, topTags] = await Promise.all([
        queryRecipes(filters),
        getTop5Tags()
    ]);

    return { recipes, topTags };
}

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

const FilterPanel: React.FC<{
    isOpen: boolean;
    onToggle: () => void;
    availableTags: string[];
}> = ({ isOpen, onToggle, availableTags }) => {
    const formRef = useRef(null);

    const [searchParams, setSearchParams] = useSearchParams();

    const name = searchParams.get('q') || '';
    const sortBy = (searchParams.get('sort') as 'rating' | 'title' | 'saves') || '';
    const myRecipes = searchParams.get('myRecipes') === 'on';
    const searchParamsSelectedTags: string[] = searchParams.get('tags')?.split(',').filter(Boolean) || [];
    const searchParamsMinRating = Number(searchParams.get('minRating')) || 0;

    const [minRating, setMinRating] = useState(searchParamsMinRating);
    const [selectedTags, setSelectedTags] = useState<string[]>(searchParamsSelectedTags);

    const handleTagToggle = (tag: string) => {
        setSelectedTags(prev =>
            prev.includes(tag) ? prev.filter(t => t !== tag) : [...prev, tag]
        );
    };

    const handleSubmit: React.FormEventHandler<HTMLFormElement> = (e) => {
        e.preventDefault();
        const newSearchParams = new URLSearchParams();

        // copy form state to search params
        const formData = new FormData(e.target as HTMLFormElement);
        for (const [key, value] of formData.entries()) {
            newSearchParams.set(key, value as string);
        }

        // handle interactive components that manage their values through state
        if (selectedTags.length > 0) newSearchParams.set('tags', selectedTags.join(','));
        if (minRating > 0) newSearchParams.set('minRating', String(minRating));

        // trigger a new read
        setSearchParams(newSearchParams);
    };

    const handleReset = () => {
        // clear components on the page
        if (formRef.current) {
            (formRef.current as HTMLFormElement).reset();
        }
        setMinRating(0);
        setSelectedTags([]);

        // trigger a new read
        setSearchParams(new URLSearchParams());
    };

    const hasFilters = Array.from(searchParams.keys()).length > 0;

    return (
        <div className="bg-card border rounded-xl mb-6 overflow-hidden">
            <button
                onClick={onToggle}
                className="w-full flex items-center justify-between p-4 hover:bg-muted/50 transition-colors"
            >
                <div className="flex items-center gap-2">
                    <Search className="w-4 h-4 text-muted-foreground" />
                    <span className="font-medium">Filter Recipes</span>
                    {hasFilters && (
                        <span className="text-xs bg-primary text-primary-foreground px-2 py-0.5 rounded-full">
                            Active
                        </span>
                    )}
                </div>
                {isOpen ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
            </button>

            {isOpen && (
                <Form onSubmit={handleSubmit} className="p-4 border-t" ref={formRef}>
                    <FieldGroup>
                        <Field>
                            <FieldLabel>Recipe Name</FieldLabel>
                            <Input
                                placeholder="e.g. Pasta, Salad..."
                                defaultValue={name}
                                name='q'
                            />
                        </Field>

                        <Field>
                            <label className="flex items-center gap-2 cursor-pointer p-1">
                                <input
                                    type="checkbox"
                                    name='myRecipes'
                                    defaultChecked={myRecipes}
                                    className="w-4 h-4 accent-primary rounded border-gray-300"
                                />
                                <span className="font-medium">Show only my recipes</span>
                            </label>
                        </Field>

                        {/* Rating */}
                        <Field>
                            <FieldLabel>Minimum Rating</FieldLabel>
                            <div className="flex items-center gap-1">
                                {[1, 2, 3, 4, 5].map((star) => (
                                    <Star
                                        key={star}
                                        className={`w-7 h-7 cursor-pointer transition-all ${star <= minRating
                                            ? "fill-amber-400 text-amber-400"
                                            : "text-muted-foreground/30 hover:text-amber-400"
                                            }`}
                                        onClick={() => setMinRating(star === minRating ? 0 : star)}
                                    />
                                ))}
                                {minRating > 0 && (
                                    <button
                                        onClick={() => setMinRating(0)}
                                        className="ml-2 text-xs text-muted-foreground hover:text-foreground"
                                    >
                                        <X className="w-4 h-4" />
                                    </button>
                                )}
                            </div>
                        </Field>

                        {/* Tags */}
                        <Field>
                            <FieldLabel>Tags</FieldLabel>
                            <div className="flex flex-wrap gap-2">
                                {availableTags.map((tag) => (
                                    <button
                                        key={tag}
                                        type="button"
                                        onClick={() => handleTagToggle(tag)}
                                        className={`px-3 py-1.5 text-sm rounded-full border transition-all ${selectedTags.includes(tag)
                                            ? "bg-primary text-primary-foreground border-primary"
                                            : "bg-background border-border hover:border-primary/50"
                                            }`}
                                    >
                                        {tag}
                                    </button>
                                ))}
                            </div>
                        </Field>

                        {/* Sort By */}
                        <Field>
                            <FieldLabel>Sort By</FieldLabel>
                            <div className="flex gap-4">
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input
                                        type="radio"
                                        name="sort"
                                        value="rating"
                                        defaultChecked={sortBy === 'rating'}
                                        className="accent-primary"
                                    />
                                    <span className="text-sm">Rating</span>
                                </label>
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input
                                        type="radio"
                                        name="sort"
                                        value="title"
                                        defaultChecked={sortBy === 'title'}
                                        className="accent-primary"
                                    />
                                    <span className="text-sm">Alphabetical</span>
                                </label>
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input
                                        type="radio"
                                        name="sort"
                                        value="saves"
                                        defaultChecked={sortBy === 'saves'}
                                        className="accent-primary"
                                    />
                                    <span className="text-sm">Saves</span>
                                </label>
                            </div>
                        </Field>

                        {/* Actions */}
                        <div className="flex gap-3 pt-2">
                            <Button type="button" variant="outline" onClick={handleReset} className="flex-1">
                                Reset
                            </Button>
                            <Button type="submit" className="flex-1">
                                Apply Filters
                            </Button>
                        </div>
                    </FieldGroup>
                </Form>
            )}
        </div>
    );
};


export default function RecipesPage({ loaderData }: Route.loaderData) {
    const { recipes, topTags } = loaderData;
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const [filterOpen, setFilterOpen] = useState(false);


    if (!recipes || recipes.length === 0) {
        const hasFilters = searchParams.toString().length > 0;
        if (hasFilters) {
            return (
                <div className="p-4">
                    <FilterPanel
                        isOpen={filterOpen}
                        onToggle={() => setFilterOpen(!filterOpen)}
                        availableTags={topTags}
                    />
                    <div className="text-center py-12">
                        <p className="text-muted-foreground">No recipes match your filters.</p>
                        <Button
                            variant="link"
                            onClick={() => navigate('/recipes')}
                            className="mt-2"
                        >
                            Clear all filters
                        </Button>
                    </div>
                </div>
            );
        }
        return <ZeroState />;
    }

    return (
        <div>
            <FilterPanel
                isOpen={filterOpen}
                onToggle={() => setFilterOpen(!filterOpen)}
                availableTags={topTags}
            />
            <h3 className="mb-4">{recipes.length} recipes</h3>
            <ItemGroup className='gap-4'>
                {recipes.map((recipe: Recipe) => (
                    <Item key={recipe.id} variant="outline">
                        <ItemContent>
                            <ItemTitle>{recipe.title}</ItemTitle>
                            <ItemDescription>
                                {recipe.tags?.join(", ") || "No tags"}
                            </ItemDescription>
                        </ItemContent>
                        <ItemActions>
                            <Button variant="outline" size="sm" asChild>
                                <Link to={`/recipes/${recipe.id}`}>Open</Link>
                            </Button>
                        </ItemActions>
                    </Item>
                ))}
            </ItemGroup>
        </div>
    );
}