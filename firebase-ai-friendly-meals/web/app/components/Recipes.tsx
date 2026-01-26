import React, { useState } from "react";
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
import { useLoaderData, Link, useSearchParams, useNavigate } from "react-router";
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

// Common tags for filtering
export const AVAILABLE_TAGS = ["Quick & Easy", "Vegan", "Gluten-Free", "High Protein", "Low Carb", "Dessert"];

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
    searchParams: URLSearchParams;
    onApply: (params: URLSearchParams) => void;
}> = ({ isOpen, onToggle, searchParams, onApply }) => {
    const [name, setName] = useState(searchParams.get('q') || '');
    const [minRating, setMinRating] = useState(Number(searchParams.get('minRating')) || 0);
    const [selectedTags, setSelectedTags] = useState<string[]>(
        searchParams.get('tags')?.split(',').filter(Boolean) || []
    );
    const [sortBy, setSortBy] = useState<'rating' | 'title' | ''>(
        (searchParams.get('sort') as 'rating' | 'title') || ''
    );
    const [myRecipes, setMyRecipes] = useState(searchParams.get('myRecipes') === 'true');
    const [likedOnly, setLikedOnly] = useState(searchParams.get('likedOnly') === 'true');

    const handleTagToggle = (tag: string) => {
        setSelectedTags(prev =>
            prev.includes(tag) ? prev.filter(t => t !== tag) : [...prev, tag]
        );
    };

    const handleApply = () => {
        const params = new URLSearchParams();
        if (name.trim()) params.set('q', name.trim());
        if (minRating > 0) params.set('minRating', String(minRating));
        if (selectedTags.length > 0) params.set('tags', selectedTags.join(','));
        if (sortBy) params.set('sort', sortBy);
        if (myRecipes) params.set('myRecipes', 'true');
        if (likedOnly) params.set('likedOnly', 'true');
        onApply(params);
    };

    const handleReset = () => {
        setName('');
        setMinRating(0);
        setSelectedTags([]);
        setSortBy('');
        setMyRecipes(false);
        setLikedOnly(false);
        onApply(new URLSearchParams());
    };

    const hasFilters = name || minRating > 0 || selectedTags.length > 0 || sortBy || myRecipes || likedOnly;

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
                <div className="p-4 border-t">
                    <FieldGroup>
                        {/* Recipe Name */}
                        <Field>
                            <FieldLabel>Recipe Name</FieldLabel>
                            <Input
                                placeholder="e.g. Pasta, Salad..."
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                            />
                        </Field>

                        {/* My Recipes Toggle */}
                        <Field>
                            <label className="flex items-center gap-2 cursor-pointer p-1">
                                <input
                                    type="checkbox"
                                    checked={myRecipes}
                                    onChange={(e) => setMyRecipes(e.target.checked)}
                                    className="w-4 h-4 accent-primary rounded border-gray-300"
                                />
                                <span className="font-medium">Show only my recipes</span>
                            </label>
                        </Field>

                        {/* Liked Recipes Toggle */}
                        <Field>
                            <label className="flex items-center gap-2 cursor-pointer p-1">
                                <input
                                    type="checkbox"
                                    checked={likedOnly}
                                    onChange={(e) => setLikedOnly(e.target.checked)}
                                    className="w-4 h-4 accent-primary rounded border-gray-300"
                                />
                                <span className="font-medium">Show only liked recipes</span>
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
                                {AVAILABLE_TAGS.map((tag) => (
                                    <button
                                        key={tag}
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
                                        checked={sortBy === 'rating'}
                                        onChange={() => setSortBy('rating')}
                                        className="accent-primary"
                                    />
                                    <span className="text-sm">Rating</span>
                                </label>
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input
                                        type="radio"
                                        name="sort"
                                        checked={sortBy === 'title'}
                                        onChange={() => setSortBy('title')}
                                        className="accent-primary"
                                    />
                                    <span className="text-sm">Alphabetical</span>
                                </label>
                            </div>
                        </Field>

                        {/* Actions */}
                        <div className="flex gap-3 pt-2">
                            <Button variant="outline" onClick={handleReset} className="flex-1">
                                Reset
                            </Button>
                            <Button onClick={handleApply} className="flex-1">
                                Apply Filters
                            </Button>
                        </div>
                    </FieldGroup>
                </div>
            )}
        </div>
    );
};

const RecipesList: React.FC = () => {
    const recipes = useLoaderData<Array<Recipe>>();
    const [searchParams] = useSearchParams();
    const navigate = useNavigate();
    const [filterOpen, setFilterOpen] = useState(false);

    const handleApplyFilters = (params: URLSearchParams) => {
        navigate(`/recipes?${params.toString()}`);
    };

    if (!recipes || recipes.length === 0) {
        // Check if filters are applied
        const hasFilters = searchParams.toString().length > 0;
        if (hasFilters) {
            return (
                <div className="p-4">
                    <FilterPanel
                        isOpen={filterOpen}
                        onToggle={() => setFilterOpen(!filterOpen)}
                        searchParams={searchParams}
                        onApply={handleApplyFilters}
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
        <div className="p-4">
            <FilterPanel
                isOpen={filterOpen}
                onToggle={() => setFilterOpen(!filterOpen)}
                searchParams={searchParams}
                onApply={handleApplyFilters}
            />
            <ItemGroup className='gap-4'>
                {recipes.map(recipe => (
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
};

export default RecipesList;