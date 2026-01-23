import type { Route } from "./+types/chat";
import ChatLayout from "../components/ChatLayout";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Chat - Friendly Meals" },
        { name: "description", content: "Chat about cooking with AI" },
    ];
}

export default function ChatPage() {
    return <ChatLayout />;
}
