import { getAuth, signInAnonymously } from "firebase/auth";

import { firebaseApp } from "./firebase";

export async function getUser() {
    const auth = getAuth(firebaseApp);
    await auth.authStateReady();

    if (auth.currentUser) {
        return auth.currentUser;
    }

    const credential = await signInAnonymously(auth);
    return credential.user;
}