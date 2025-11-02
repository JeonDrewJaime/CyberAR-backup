import { collection, getDocs, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';

export const getModules = async () => {
    const response = await getDocs(collection(db, 'modules'));
    const modules = response.docs.map(
        doc => ({
            id: doc.id,
            ...doc.data()
        })
    );
    let sortedModules = modules.sort((a, b) => a.moduleNumber - b.moduleNumber);
    return sortedModules;
}

export const createModule = async (module) => {
    try {
        module.createdDate = new Date();
        const moduleRef = collection(db, 'modules');
        const docRef = await addDoc(moduleRef, module);
        return docRef.id;
    } catch (error) {
        console.error('Error creating module:', error);
        throw error;
    }
};

export const editModule = async (moduleId, updatedData) => {
    try {
        updatedData.updatedDate = new Date();
        const moduleRef = doc(db, 'modules', moduleId);
        await updateDoc(moduleRef, updatedData);
        return moduleId;
    } catch (error) {
        console.error('Error updating module:', error);
        throw error;
    }
};

export const deleteModule = async (moduleId) => {
    try {
        const moduleRef = doc(db, 'modules', moduleId);
        await deleteDoc(moduleRef);
    } catch (error) {
        console.error('Error deleting module:', error);
        throw error;
    }
};