import { useNavigate } from 'react-router-dom';
// import { signOut } from 'firebase/auth';
// import { auth } from '../../firebase';

function AdminNavbar() {
    const navigate = useNavigate();

    const handleSignOut = async () => {
        try {
            // await signOut(auth);
            localStorage.removeItem('user');
            navigate('/login');
        } catch (error) {
            console.error("Sign out error:", error);
        }
    };

    return (
        <div className="fixed-top p-2 bg-white" style={{ height: '56px', zIndex: '100' }}>
            <div className="d-flex justify-content-end align-items-center" style={{ height: '100%' }}>
                <div onClick={handleSignOut} style={{ cursor: 'pointer' }}>
                    <i className="bi bi-box-arrow-right me-2 fs-5"></i>
                </div>
            </div>
        </div>
    );
};

export default AdminNavbar;
