import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase';


export const getDashboardCardsData = async () => {
    try {
        const usersRef = collection(db, 'users');
        const usersDocs = await getDocs(usersRef);

        const modulesRef = collection(db, 'modules');
        const modulesDocs = await getDocs(modulesRef);

        const totalLessons = modulesDocs.docs.reduce((acc, doc) => {
            const lessons = doc.data().lessons || [];
            return acc + lessons.length;
        }, 0);

        const assessmentsRef = collection(db, 'assessments');
        const assessmentsDocs = await getDocs(assessmentsRef);

        return {
            users: usersDocs.docs.length,
            modules: modulesDocs.docs.length,
            lessons: totalLessons,
            assessments: assessmentsDocs.docs.length,
        }
    } catch (error) {
        console.log(error)
    }
}

export const getDashboardLeaderboardData = async () => {
    try {
        const recordsRef = collection(db, 'records');
        const recordsDocs = await getDocs(recordsRef);

        const leaderboardData = recordsDocs.docs.map(doc => {
            const student = doc.data();
            const scores = student.scores || [];

            const totalScore = scores.reduce((acc, score) => acc + Number(score.QuizScore), 0);

            return {
                name: student.name,
                email: student.email,
                totalScore: totalScore,
            };
        });

        leaderboardData.sort((a, b) => b.totalScore - a.totalScore);
        return leaderboardData;
    } catch (error) {
        console.log(error)
    }
}

export const getLessonStatsData = async () => {
    try {
        const modulesRef = collection(db, 'modules');
        const modulesDocs = await getDocs(modulesRef);
        let sortedModules = modulesDocs.docs
            .map(doc => doc.data())
            .sort((a, b) => a.moduleNumber - b.moduleNumber);

        const moduleTitles = sortedModules.map(module => module.title);
        const lessonsPerModule = modulesDocs.docs.map(doc => {
            const moduleData = doc.data();
            return moduleData.lessons ? moduleData.lessons.length : 0;
        });

        return {
            labels: moduleTitles,
            datasets: [
                {
                    label: 'Lessons per Module',
                    data: lessonsPerModule,
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1,
                },
            ],
        };
    } catch (error) {
        console.error('Error fetching lesson stats:', error);
        return {
            labels: [],
            datasets: [{
                label: 'Lessons per Module',
                data: [],
                backgroundColor: 'rgba(255, 99, 132, 0.2)',
                borderColor: 'rgba(255, 99, 132, 1)',
                borderWidth: 1,
            }],
        };
    }
};

export const getStudentScoresPerModule = async () => {
    try {
        const recordsRef = collection(db, 'records');
        const modulesRef = collection(db, 'modules');

        const recordsDocs = await getDocs(recordsRef);
        const modulesDocs = await getDocs(modulesRef);

        let sortedModules = modulesDocs.docs
            .map(doc => doc.data())
            .sort((a, b) => a.moduleNumber - b.moduleNumber);

        const moduleTitles = sortedModules.map(module => module.title);

        const scoreMap = moduleTitles.reduce((acc, title) => {
            acc[title] = { totalScore: 0, count: 0 };
            return acc;
        }, {});

        recordsDocs.docs.forEach(doc => {
            const student = doc.data();
            const scores = student.scores || [];

            scores.forEach(score => {
                if (score.CourseName && scoreMap[score.CourseName]) {
                    scoreMap[score.CourseName].totalScore += Number(score.QuizScore);
                    scoreMap[score.CourseName].count += 1;
                }
            });
        });

        const labels = Object.keys(scoreMap);
        const data = labels.map(label => {
            const module = scoreMap[label];
            return module.count > 0 ? module.totalScore / module.count : 0;
        });

        return {
            labels: labels,
            datasets: [
                {
                    label: 'Average Score per Module',
                    data: data,
                    backgroundColor: 'rgba(0, 123, 255, 0.2)',
                    borderColor: 'rgba(0, 123, 255, 1)',
                    borderWidth: 1,
                },
            ],
        };
    } catch (error) {
        console.error('Error fetching student scores per module:', error);
        return {
            labels: [],
            datasets: [{
                label: 'Average Score per Module',
                data: [],
                backgroundColor: 'rgba(255, 99, 132, 0.2)',
                borderColor: 'rgba(255, 99, 132, 1)',
                borderWidth: 1,
            }],
        };
    }
};