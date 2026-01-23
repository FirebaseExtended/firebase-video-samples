import { type RouteConfig, index, route, layout } from "@react-router/dev/routes";

export default [
    // Home page - no layout wrapper
    index("routes/home.tsx"),

    // Routes wrapped in the main layout
    layout("components/Layout.tsx", [
        route("chat", "routes/chat.tsx"),
        route("generate", "routes/generate.tsx"),
        route("image", "routes/image.tsx"),
        route("recipes", "routes/recipes.tsx"),
        route("recipes/:recipeId", "routes/recipe.$recipeId.tsx"),
    ]),
] satisfies RouteConfig;
