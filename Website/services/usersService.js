import { collection, getDocs, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';

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
    try {
        user.createdDate = new Date();
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