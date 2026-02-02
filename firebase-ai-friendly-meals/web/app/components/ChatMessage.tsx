import React from "react";
import Markdown from "react-markdown";

const ChatMessage: React.FC<{ role: "user" | "model"; message: string }> = ({
  role,
  message,
}) => {
  return (
    <div className={`flex ${role === 'user' ? 'justify-end' : 'justify-start'}`}>
      <div className={`rounded-lg px-4 py-2 max-w-[80%] ${role === 'user'
        ? 'bg-primary text-primary-foreground rounded-br-none'
        : 'bg-muted text-muted-foreground rounded-bl-none'
        }`}>
        <div className={`prose prose-slate ${role === 'user' ? 'prose-invert' : ''}`}>
          <Markdown>{message}</Markdown>
        </div>
      </div>
    </div>
  );
};

export default ChatMessage;
