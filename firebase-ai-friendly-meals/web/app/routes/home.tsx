import type { Route } from "./+types/home";
import Home from "../components/Home";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Friendly Meals - AI-Powered Recipe Generator" },
        { name: "description", content: "Generate recipes with Firebase AI Logic and Firestore Pipelines" },
    ];
}

export default function HomePage() {
    return <Home />;
}
