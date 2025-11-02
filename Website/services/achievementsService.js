import { collection, getDocs, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';

export const getAchievements = async () => {
    const response = await getDocs(collection(db, 'achievements'));
    const achievements = response.docs.map(
        doc => ({
            id: doc.id,
            ...doc.data()
        })
    );
    return achievements;
}

export const createAchievement = async (achievement) => {
    try {
        achievement.createdDate = new Date();
        const achievementRef = collection(db, 'achievements');
        const docRef = await addDoc(achievementRef, achievement);
        return docRef.id;
    } catch (error) {
        console.error('Error creating achievement:', error);
        throw error;
    }
};

export const editAchievement = async (achievementId, updatedData) => {
    try {
        updatedData.updatedDate = new Date();
        const achievementRef = doc(db, 'achievements', achievementId);
        await updateDoc(achievementRef, updatedData);
        return achievementId;
    } catch (error) {
        console.error('Error updating achievement:', error);
        throw error;
    }
};

export const deleteAchievement = async (achievementId) => {
    try {
        const achievementRef = doc(db, 'achievements', achievementId);
        await deleteDoc(achievementRef);
    } catch (error) {
        console.error('Error deleting achievement:', error);
        throw error;
    }
};