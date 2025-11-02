import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
    apiKey: "AIzaSyAXlo7iRA1mb8c4isxecVNKXDhYaqHlM2g",
    authDomain: "cyberar-23051.firebaseapp.com",
    projectId: "cyberar-23051",
    storageBucket: "cyberar-23051.firebasestorage.app",
    messagingSenderId: "1096486176417",
    appId: "1:1096486176417:web:bacd69a6388d931622d2e0"
};


// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

export { db, auth };
