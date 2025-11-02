import AdminNavbar from "../../components/AdminNavbar"
import AdminSidebar from "../../components/AdminSidebar"
import AchievementsTable from "../../components/tables/AchievementsTable"

export const Achievements = () => {
    return (
        <>
            <AdminNavbar />
            <div className="d-flex">
                <AdminSidebar />
                <div className="flex-grow-1">
                    <div className="px-3" style={{ marginLeft: '250px', marginTop: '56px' }}>
                        <AchievementsTable />
                    </div>
                </div>
            </div>
        </>
    )
}