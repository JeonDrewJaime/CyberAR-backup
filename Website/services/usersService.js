import { collection, getDocs, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { createUserWithEmailAndPassword, signOut, getAuth } from 'firebase/auth';
import { initializeApp, getApp } from 'firebase/app';
import { db, auth } from '../firebase';

// Create a separate Firebase app instance for user creation to avoid disrupting admin session
const createUserAuthApp = () => {
    const firebaseConfig = {
        apiKey: "AIzaSyAXlo7iRA1mb8c4isxecVNKXDhYaqHlM2g",
        authDomain: "cyberar-23051.firebaseapp.com",
        projectId: "cyberar-23051",
        storageBucket: "cyberar-23051.firebasestorage.app",
        messagingSenderId: "1096486176417",
        appId: "1:1096486176417:web:bacd69a6388d931622d2e0"
    };
    
    // Use a unique name for this app instance
    try {
        return initializeApp(firebaseConfig, 'userCreationApp');
    } catch (error) {
        // If app already exists, get it
        try {
            return getApp('userCreationApp');
        } catch (e) {
            throw error;
        }
    }
};

export const getUsers = async () => {
    const response = await getDocs(collection(db, 'users'));
    const users = response.docs.map(
        doc => ({
            id: doc.id,
            ...doc.data()
        })
    );
    return users;
}

export const createUser = async (user) => {
    let userCreationAuth = null;
    try {
        // Create a separate Firebase app instance for user creation
        // This prevents disrupting the admin's current session
        const userCreationApp = createUserAuthApp();
        userCreationAuth = getAuth(userCreationApp);

        // Create Firebase Auth user using the separate auth instance
        let authUser = null;
        try {
            const userCredential = await createUserWithEmailAndPassword(
                userCreationAuth,
                user.email,
                user.password
            );
            authUser = userCredential.user;
            
            // Sign out the newly created user from the separate auth instance
            await signOut(userCreationAuth);
        } catch (authError) {
            console.error('Error creating Firebase Auth user:', authError);
            throw new Error(`Failed to create authentication account: ${authError.message}`);
        }

        // Create Firestore user document with auth UID
        user.createdDate = new Date();
        user.uid = authUser.uid; // Store the Firebase Auth UID
        delete user.password; // Don't store password in Firestore
        
        const userRef = collection(db, 'users');
        const docRef = await addDoc(userRef, user);
        return docRef.id;
    } catch (error) {
        console.error('Error creating user:', error);
        throw error;
    }
};

export const editUser = async (userId, updatedData) => {
    try {
        updatedData.updatedDate = new Date();
        const userRef = doc(db, 'users', userId);
        await updateDoc(userRef, updatedData);
        return userId;
    } catch (error) {
        console.error('Error updating user:', error);
        throw error;
    }
};

export const deleteUser = async (userId) => {
    try {
        const userRef = doc(db, 'users', userId);
        await deleteDoc(userRef);
    } catch (error) {
        console.error('Error deleting user:', error);
        throw error;
    }
};