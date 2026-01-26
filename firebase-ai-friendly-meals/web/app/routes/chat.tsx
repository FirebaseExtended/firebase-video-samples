import type { Route } from "./+types/chat";
import React, { useCallback, useMemo, useState } from "react";
import { ai } from "../firebase/firebase";
import { getGenerativeModel } from "firebase/ai";
import ChatMessage from "@/components/ChatMessage";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Spinner } from "@/components/ui/spinner";

export function meta({ }: Route.MetaArgs) {
    return [
        { title: "Chat - Friendly Meals" },
        { name: "description", content: "Chat about cooking with AI" },
    ];
}

export default function ChatPage() {
    const [loading, setLoading] = useState(false);
    const [history, setHistory] = useState<
        Array<{ role: "user" | "model"; message: string; timestamp: number }>
    >([]);
    const chat = useMemo(() => {
        // Create a `GenerativeModel` instance with the desired model.
        const model = getGenerativeModel(ai, {
            model: "gemini-2.5-flash",
            generationConfig: { maxOutputTokens: 1000 },
            systemInstruction:
                "You're a recipe recommendation chat bot. Keep responses brief, since they need to fit in a chat window.",
        });
        return model.startChat();
    }, []);

    const updateModelMessage = useCallback(
        (newMessage: string) => {
            setHistory((prevHistory) => {
                const newHistory = structuredClone(prevHistory);
                const modelMessage = newHistory.at(-1);

                if (!modelMessage || modelMessage.role !== "model") {
                    console.log(newHistory, prevHistory);
                    throw new Error("could not find message from model");
                }

                if (modelMessage.message === "...") {
                    modelMessage.message = "";
                }
                modelMessage.message += newMessage;
                return newHistory;
            });
        },
        [setHistory]
    );

    async function sendMessage(message: string) {
        setLoading(true);
        setHistory([
            ...history,
            { role: "user", message, timestamp: Date.now() },
            // add a placeholder for the model's message
            { role: "model", message: "...", timestamp: Date.now() + 500 },
        ]);

        // Uncomment below for non-streaming code:
        //
        // let generatedText: string;
        // try {
        //   const { response } = await chat.sendMessage(message);
        //   generatedText = response.text();
        // } catch (e) {
        //   generatedText = (e as Error).message;
        // }
        //
        // updateModelMessage(generatedText);

        const { stream } = await chat.sendMessageStream(message);

        try {
            for await (const chunk of stream) {
                console.log(chunk.text());
                updateModelMessage(chunk.text());
            }
        } catch (e) {
            updateModelMessage((e as Error).message);
        }

        setLoading(false);
    }

    return (
        <Card className="h-[600px] flex flex-col max-w-2xl mx-auto">
            <CardHeader>
                <CardTitle>Chat with Chef AI</CardTitle>
            </CardHeader>
            <CardContent className="flex-1 overflow-auto p-4 space-y-4">
                {history.map((historyItem) => (
                    <ChatMessage
                        key={`${historyItem.timestamp}:${historyItem.role}`}
                        {...historyItem}
                    />
                ))}
                <div style={{ overflowAnchor: "auto", height: "1px" }}></div>
            </CardContent>
            <CardFooter className="border-t">
                <form
                    className="flex w-full gap-2"
                    onSubmit={async (e) => {
                        e.preventDefault();

                        // get the message
                        const formData = new FormData(e.currentTarget);
                        const userMessage = formData.get("user-message");

                        // send the message to the model
                        if (userMessage && typeof userMessage === "string") {
                            await sendMessage(userMessage);
                        }

                        // reset the input
                        const input = document.getElementById(
                            "user-message"
                        ) as HTMLInputElement;
                        input.value = "";
                        input.focus();
                    }}
                >
                    <Input
                        className="flex-1"
                        disabled={loading}
                        type="text"
                        id="user-message"
                        name="user-message"
                        placeholder="Ask for a recipe..."
                        autoFocus
                    />
                    <Button type="submit" disabled={loading}>
                        {loading && <Spinner className="mr-2 h-4 w-4" />}
                        {loading ? "Sending..." : "Send"}
                    </Button>
                </form>
            </CardFooter>
        </Card>
    );
};
