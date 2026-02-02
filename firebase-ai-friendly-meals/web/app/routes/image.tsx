import type { Route } from "./+types/image";
import ImageLayout from "../components/ImageLayout";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Scan Recipe - Friendly Meals" },
        { name: "description", content: "Scan an image to extract a recipe" },
    ];
}

export default function ImagePage() {
    return <ImageLayout />;
}
