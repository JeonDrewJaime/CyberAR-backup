import { useEffect, useState } from "react"
import AdminNavbar from "../../components/AdminNavbar"
import AdminSidebar from "../../components/AdminSidebar"
import DashboardCards from "../../components/dashboard/DashboardCards"
import {
    getDashboardCardsData,
    getDashboardLeaderboardData,
    getLessonStatsData,
    getStudentScoresPerModule
} from "../../services/dashboardService";
import Loading from "../../components/Loading"
import DashboardLeaderboard from "../../components/dashboard/DashboardLeaderboard"
import { Bar } from 'react-chartjs-2';

import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

export const Dashboard = () => {
    const [loading, setLoading] = useState(true);
    const [dashboardCardsData, setDashboardCardsData] = useState([]);
    const [leaderboardData, setLeaderboardData] = useState([]);
    const [lessonStatsData, setLessonStatsData] = useState([]);
    const [studentScoresData, setStudentScoresData] = useState([]);

    useEffect(() => {
        getStudentScoresData();
        getCardsData();
        getLeaderboardData();
        getLessonStatsChartData();
    }, [])

    const getCardsData = async () => {
        setLoading(true);
        try {
            const response = await getDashboardCardsData();
            const cardsData = [
                {
                    title: 'Total Users',
                    value: response.users,
                },
                {
                    title: 'No. of Modules',
                    value: response.modules,
                },
                {
                    title: 'No. of Lessons',
                    value: response.lessons,
                },
                {
                    title: 'Total Assessments',
                    value: response.assessments,
                }
            ];
            setDashboardCardsData(cardsData);
            setLoading(false);
        } catch (error) {
            console.log(error)
        }
    };

    const getLeaderboardData = async () => {
        setLoading(true);
        try {
            const response = await getDashboardLeaderboardData();
            setLeaderboardData(response);
            setLoading(false);
        } catch (error) {
            console.log(error)
        }
    };

    const getLessonStatsChartData = async () => {
        setLoading(true);
        try {
            const response = await getLessonStatsData();
            setLessonStatsData(response);
            setLoading(false);
        } catch (error) {
            console.log(error)
        }
    };

    const getStudentScoresData = async () => {
        setLoading(true);
        try {
            const response = await getStudentScoresPerModule();
            setStudentScoresData(response);
            setLoading(false);
        } catch (error) {
            console.log(error)
        }
    };

    return (
        <>
            <AdminNavbar />
            <div className="d-flex">
                <AdminSidebar />
                <div className="flex-grow-1">
                    <div
                        className="px-3"
                        style={{ marginLeft: "250px", marginTop: "56px" }}
                    >
                        {loading && <Loading />}
                        {!loading && (
                            <>
                                <DashboardCards dashboardCardsData={dashboardCardsData} />

                                <div className="container mt-3">
                                    <div className="row">
                                        <div className="col-md-6 mb-3">
                                            <span className="fs-5 fw-bold mb-4">Lessons Per Module</span>
                                            <div style={{ height: '400px' }}>
                                                <Bar data={lessonStatsData} options={{ responsive: true }} />
                                            </div>
                                        </div>
                                        <div className="col-md-6 mb-3">
                                            <span className="fs-5 fw-bold mb-4">Average Score Per Module</span>
                                            <div style={{ height: '400px' }}>
                                                <Bar data={studentScoresData} options={{ responsive: true }} />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <DashboardLeaderboard leaderboardData={leaderboardData} />
                            </>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
}