import type { Route } from "./+types/generate";
import TextLayout from "../components/TextLayout";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Generate Recipe - Friendly Meals" },
        { name: "description", content: "Generate a new recipe with AI" },
    ];
}

export default function GeneratePage() {
    return <TextLayout />;
}
