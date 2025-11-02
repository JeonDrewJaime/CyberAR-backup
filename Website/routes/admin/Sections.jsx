import AdminNavbar from "../../components/AdminNavbar";
import AdminSidebar from "../../components/AdminSidebar";
import SectionsTable from "../../components/tables/SectionsTable";

const Sections = () => {
    return (
        <>
            <AdminNavbar />
            <div className="d-flex">
                <AdminSidebar />
                <div className="flex-grow-1">
                    <div className="px-3" style={{ marginLeft: '250px', marginTop: '56px' }}>
                        <SectionsTable />
                    </div>
                </div>
            </div>
        </>
    )
}

export default Sections
