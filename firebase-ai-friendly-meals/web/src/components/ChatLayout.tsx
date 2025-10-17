import React, { useCallback, useMemo, useState } from "react";
import styles from "../styles/Layout.module.css";
import { ai } from "../firebase/firebase";
import { getGenerativeModel } from "firebase/ai";
import ChatMessage from "./ChatMessage";

const Layout: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [history, setHistory] = useState<
    Array<{ role: "user" | "model"; message: string }>
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

  const updateModelMessage = useCallback((newMessage) => {
    setHistory((prevHistory) => {
        const newHistory = structuredClone(prevHistory);
        const modelMessage = newHistory.at(-1);

        if (!modelMessage || modelMessage.role !== 'model') {
            console.log(newHistory, prevHistory);
            throw new Error('could not find message from model');
        }

        if (modelMessage.message === "...") {
            modelMessage.message = "";
          }
          modelMessage.message += newMessage;
          return newHistory;
      });
  }, [setHistory]);

  async function sendMessage(message: string) {
    setLoading(true);
    setHistory([
      ...history,
      { role: "user", message },
      // add a placeholder for the model's message
      { role: "model", message: "..." },
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
    <div className={styles.mainContainer}>
      <h1>Friendly Meals</h1>
      <div className={styles.contentContainer}>
        <div
          className={[styles.layoutPane, styles.output, styles.chat].join(" ")}
        >
          {history.map((historyItem) => (
            <ChatMessage {...historyItem} />
          ))}
          <div style={{ overflowAnchor: "auto", height: "1px" }}></div>
        </div>
        <form
          className={[styles.layoutPane, styles.input].join(" ")}
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
          <input
            className={styles.chatInput}
            disabled={loading}
            type="text"
            id="user-message"
            name="user-message"
            autoFocus
          ></input>
        </form>
      </div>
    </div>
  );
};

export default Layout;
