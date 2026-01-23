import { getAuth, signInAnonymously } from "firebase/auth";

import { firebaseApp } from "./firebase";

export async function getUser() {
    const auth = getAuth(firebaseApp);

    if (auth.currentUser) {
        console.log("User is already signed in");
        return auth.currentUser;
    }

    // check again for currentUser after authStateReady
    await auth.authStateReady();
    if (auth.currentUser) {
        console.log("User is already signed in");
        return auth.currentUser;
    }

    const credential = await signInAnonymously(auth);
    return credential.user;
}