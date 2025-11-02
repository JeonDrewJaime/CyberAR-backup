import { collection, getDocs, doc, addDoc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';

export const getAssessments = async () => {
    const response = await getDocs(collection(db, 'assessments'));
    const assessments = response.docs.map(
        doc => ({
            id: doc.id,
            ...doc.data()
        })
    );
    console.log(assessments)
    return assessments;
}

export const createAssessment = async (assessment) => {
    try {
        assessment.createdDate = new Date();
        const assessmentRef = collection(db, 'assessments');
        const docRef = await addDoc(assessmentRef, assessment);
        return docRef.id;
    } catch (error) {
        console.error('Error creating assessment:', error);
        throw error;
    }
};

export const editAssessment = async (assessmentId, updatedData) => {
    try {
        updatedData.updatedDate = new Date();
        const assessmentRef = doc(db, 'assessments', assessmentId);
        await updateDoc(assessmentRef, updatedData);
        return assessmentId;
    } catch (error) {
        console.error('Error updating assessment:', error);
        throw error;
    }
};

export const deleteAssessment = async (assessmentId) => {
    try {
        const assessmentRef = doc(db, 'assessments', assessmentId);
        await deleteDoc(assessmentRef);
        return assessmentId;
    } catch (error) {
        console.error('Error deleting assessment:', error);
        throw error;
    }
};