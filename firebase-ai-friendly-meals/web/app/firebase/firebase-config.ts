import { initializeApp } from "firebase/app";

// Your web app's Firebase configuration
export const firebaseConfig = null;

if (!firebaseConfig) {
  throw new Error('No firebase config found. Set the firebaseConfig object in firebase-config.ts');
}

// Initialize Firebase
initializeApp(firebaseConfig);
