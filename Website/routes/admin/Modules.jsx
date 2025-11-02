import AdminNavbar from "../../components/AdminNavbar";
import AdminSidebar from "../../components/AdminSidebar";
import ModulesTable from "../../components/tables/ModulesTable";

function Modules() {
    return (
        <>
            <AdminNavbar />
            <div className="d-flex">
                <AdminSidebar />
                <div className="flex-grow-1">
                    <div className="px-3" style={{ marginLeft: '250px', marginTop: '56px' }}>
                        <ModulesTable />
                    </div>
                </div>
            </div>
        </>
    )
}

export default Modules
