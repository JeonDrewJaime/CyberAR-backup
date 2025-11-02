import AdminNavbar from "../../components/AdminNavbar"
import AdminSidebar from "../../components/AdminSidebar"
import AssessmentsTable from "../../components/tables/AssessmentsTable"

export const Assessments = () => {
    return (
        <>
            <AdminNavbar />
            <div className="d-flex">
                <AdminSidebar />
                <div className="flex-grow-1">
                    <div className="px-3" style={{ marginLeft: '250px', marginTop: '56px' }}>
                        <AssessmentsTable />
                    </div>
                </div>
            </div>
        </>
    )
}

