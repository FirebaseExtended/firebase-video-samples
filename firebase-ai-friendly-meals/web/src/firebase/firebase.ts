import { initializeApp } from "firebase/app";
import { firebaseConfig } from "./firebase-config";
import { getAI, GoogleAIBackend } from "firebase/ai";

const firebaseApp = initializeApp(firebaseConfig);

// Initialize the Gemini Developer API backend service
const ai = getAI(firebaseApp, { backend: new GoogleAIBackend() });

export { ai };
