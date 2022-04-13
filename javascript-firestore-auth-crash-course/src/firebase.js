/**
 * @license
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { initializeApp, getApps } from 'firebase/app'
import {
  getFirestore,
  connectFirestoreEmulator,
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  serverTimestamp,
  enableMultiTabIndexedDbPersistence
} from 'firebase/firestore'
import { getAuth, connectAuthEmulator, onAuthStateChanged } from 'firebase/auth'
import { config } from './config'

function initializeServices() {
  const isConfigured = getApps().length > 0
  const firebaseApp = initializeApp(config.firebase)
  const firestore = getFirestore(firebaseApp)
  const auth = getAuth(firebaseApp)
  return { firebaseApp, firestore, auth, isConfigured }
}

function connectToEmulators({ auth, firestore }) {
  if (location.hostname === 'localhost') {
    connectFirestoreEmulator(firestore, 'localhost', 8080)
    connectAuthEmulator(auth, 'http://localhost:9099')
  }
}

export function getFirebase() {
  const services = initializeServices()
  if (!services.isConfigured) {
    connectToEmulators(services)
    enableMultiTabIndexedDbPersistence(services.firestore);
  }
  return services
}

export function streamMessages({ caseId }) {
  const { firestore } = getFirebase()
  const messagesCol = collection(firestore, 'supportCases', caseId, 'messages')
  const messageQuery = query(messagesCol, orderBy('timestamp'))
  const stream = (callback) => onSnapshot(messageQuery, snapshot => {
    const messages = snapshot.docs.map(doc => {
      const isDelivered = !doc.metadata.hasPendingWrites;
      return {
        isDelivered,
        id: doc.id,
        ...doc.data()
      };
    })

    callback(messages);
  });
  
  const addMessage = (message) => addDoc(messagesCol, {
    timestamp: serverTimestamp(),
    ...message,
  });

  return { stream, addMessage };
}

export function onAuth(callback) {
  const { auth } = getFirebase();
  return onAuthStateChanged(auth, user => {
    console.log(user);
    callback(user);
  })
}

