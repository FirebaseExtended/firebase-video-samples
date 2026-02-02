import { initializeApp } from "firebase/app";
import { firebaseConfig } from "./firebase-config";
import { getAI, GoogleAIBackend } from "firebase/ai";
import { getStorage } from "firebase/storage";

export const firebaseApp = initializeApp(firebaseConfig);

// Initialize the Gemini Developer API backend service
const ai = getAI(firebaseApp, { backend: new GoogleAIBackend() });

export const storage = getStorage(firebaseApp);

export { ai };
