import { collection, getDocs, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';

export const getSections = async () => {
    const response = await getDocs(collection(db, 'sections'));
    const sections = response.docs.map(
        doc => ({
            id: doc.id,
            ...doc.data()
        })
    );

    const usersResponse = await getDocs(collection(db, 'users'));
    sections.forEach(section => {
        section.totalStudents = usersResponse.docs.filter(user => user.data().section === section.name).length;
    });

    return sections;
}

export const createSection = async (section) => {
    try {
        section.createdDate = new Date();
        const sectionRef = collection(db, 'sections');
        const docRef = await addDoc(sectionRef, section);
        return docRef.id;
    } catch (error) {
        console.error('Error creating section:', error);
        throw error;
    }
};

export const editSection = async (sectionId, updatedData) => {
    try {
        updatedData.updatedDate = new Date();
        const sectionRef = doc(db, 'sections', sectionId);
        await updateDoc(sectionRef, updatedData);
        return sectionId;
    } catch (error) {
        console.error('Error updating section:', error);
        throw error;
    }
};

export const deleteSection = async (sectionId) => {
    try {
        const sectionRef = doc(db, 'sections', sectionId);
        await deleteDoc(sectionRef);
    } catch (error) {
        console.error('Error deleting section:', error);
        throw error;
    }
};