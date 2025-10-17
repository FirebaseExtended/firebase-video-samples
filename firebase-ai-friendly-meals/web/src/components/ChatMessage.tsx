import React from "react";
import Markdown from "react-markdown";
import styles from "../styles/ChatMessage.module.css";

const ChatMessage: React.FC<{ role: "user" | "model"; message: string }> = ({
  role,
  message,
}) => {
  const classes = [
    styles.messageBubble,
    role === "user" ? styles.right : styles.left,
  ].join(" ");

  return (
    <div className={classes}>
      <Markdown>{message}</Markdown>
    </div>
  );
};

export default ChatMessage;
