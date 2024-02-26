import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';
import config from './config';

function initialize(existingApp) {
  const firebaseApp = existingApp || initializeApp(config);
  const auth = getAuth(firebaseApp);
  const firestore = getFirestore(firebaseApp);
  const storage = getStorage(firebaseApp);
  return { firebaseApp, auth, firestore, storage };
}

export function getFirebase() {
  const existingApp = getApps().at(0);
  return initialize(existingApp);
}
