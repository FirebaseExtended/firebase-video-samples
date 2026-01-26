import type { Route } from "./+types/home";
import { Button } from "@/components/ui/button"
import { Sparkles, Camera, MessageCircle, BookOpen, Flame, Database } from "lucide-react"

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Friendly Meals - AI-Powered Recipe Generator" },
        { name: "description", content: "Generate recipes with Firebase AI Logic and Firestore Pipelines" },
    ];
}

export default function HomePage() {
    return (
        <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-white to-orange-50 dark:from-emerald-950 dark:via-gray-900 dark:to-orange-950">
            {/* Hero Section */}
            <div className="flex flex-col items-center justify-center px-6 pt-16 pb-12">
                {/* Logo/Icon */}
                <div className="relative mb-8">
                    <div className="w-24 h-24 rounded-full bg-gradient-to-br from-emerald-400 to-emerald-600 flex items-center justify-center shadow-2xl shadow-emerald-500/30">
                        <Flame className="w-12 h-12 text-white" />
                    </div>
                    <div className="absolute -bottom-2 -right-2 w-10 h-10 rounded-full bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center shadow-lg">
                        <Sparkles className="w-5 h-5 text-white" />
                    </div>
                </div>

                {/* Title */}
                <h1 className="text-5xl md:text-6xl font-bold text-center bg-gradient-to-r from-emerald-600 via-emerald-500 to-orange-500 bg-clip-text text-transparent mb-4">
                    Friendly Meals
                </h1>
                <p className="text-xl md:text-2xl text-muted-foreground text-center max-w-lg mb-8">
                    AI-powered recipe generation and meal planning
                </p>

                {/* Primary CTA - Generate */}
                <Button
                    asChild
                    size="lg"
                    className="text-lg px-8 py-6 rounded-full bg-gradient-to-r from-emerald-500 to-emerald-600 hover:from-emerald-600 hover:to-emerald-700 shadow-xl shadow-emerald-500/30 transition-all hover:scale-105 hover:shadow-2xl hover:shadow-emerald-500/40 mb-12"
                >
                    <a href="/generate" className="flex items-center gap-3">
                        <Sparkles className="w-6 h-6" />
                        Generate a Recipe
                    </a>
                </Button>

                {/* Secondary Actions */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 w-full max-w-3xl">
                    <a
                        href="/image"
                        className="group flex flex-col items-center p-6 rounded-2xl bg-white/60 dark:bg-gray-800/60 backdrop-blur-sm border border-border/50 hover:border-emerald-300 hover:bg-white dark:hover:bg-gray-800 transition-all hover:shadow-lg hover:scale-[1.02]"
                    >
                        <div className="w-14 h-14 rounded-full bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center mb-3 group-hover:bg-orange-200 dark:group-hover:bg-orange-900/50 transition-colors">
                            <Camera className="w-7 h-7 text-orange-600 dark:text-orange-400" />
                        </div>
                        <span className="font-semibold text-foreground">Scan Recipe</span>
                        <span className="text-sm text-muted-foreground text-center mt-1">Upload a photo to extract recipes</span>
                    </a>

                    <a
                        href="/chat"
                        className="group flex flex-col items-center p-6 rounded-2xl bg-white/60 dark:bg-gray-800/60 backdrop-blur-sm border border-border/50 hover:border-emerald-300 hover:bg-white dark:hover:bg-gray-800 transition-all hover:shadow-lg hover:scale-[1.02]"
                    >
                        <div className="w-14 h-14 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center mb-3 group-hover:bg-blue-200 dark:group-hover:bg-blue-900/50 transition-colors">
                            <MessageCircle className="w-7 h-7 text-blue-600 dark:text-blue-400" />
                        </div>
                        <span className="font-semibold text-foreground">Chat</span>
                        <span className="text-sm text-muted-foreground text-center mt-1">Ask questions about cooking</span>
                    </a>

                    <a
                        href="/recipes"
                        className="group flex flex-col items-center p-6 rounded-2xl bg-white/60 dark:bg-gray-800/60 backdrop-blur-sm border border-border/50 hover:border-emerald-300 hover:bg-white dark:hover:bg-gray-800 transition-all hover:shadow-lg hover:scale-[1.02]"
                    >
                        <div className="w-14 h-14 rounded-full bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center mb-3 group-hover:bg-purple-200 dark:group-hover:bg-purple-900/50 transition-colors">
                            <BookOpen className="w-7 h-7 text-purple-600 dark:text-purple-400" />
                        </div>
                        <span className="font-semibold text-foreground">My Recipes</span>
                        <span className="text-sm text-muted-foreground text-center mt-1">Browse your saved collection</span>
                    </a>
                </div>
            </div>

            {/* Footer Badge */}
            <div className="fixed bottom-0 left-0 right-0 flex justify-center pb-6">
                <div className="flex items-center gap-3 px-5 py-3 rounded-full bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border border-border/50 shadow-lg">
                    <div className="flex items-center gap-1.5">
                        <Sparkles className="w-4 h-4 text-amber-500" />
                        <span className="text-sm font-medium text-foreground">Firebase AI Logic</span>
                    </div>
                    <span className="text-muted-foreground">+</span>
                    <div className="flex items-center gap-1.5">
                        <Database className="w-4 h-4 text-emerald-500" />
                        <span className="text-sm font-medium text-foreground">Firestore Pipelines</span>
                    </div>
                    <span className="text-xs text-muted-foreground ml-1">Sample App</span>
                </div>
            </div>
        </div>
    )
}