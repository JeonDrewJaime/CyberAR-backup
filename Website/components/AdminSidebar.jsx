import { useContext, useState } from 'react'
import { AuthContext } from '../auth/AuthContext';
import { Link } from 'react-router-dom';
import stiLogo from '../assets/sti-icon.png';

function AdminSidebar() {
    const { currentUser } = useContext(AuthContext)

    const basePath = currentUser?.isTeacher ? '/teacher' : '/admin';

    return (
        <div
            className="bg-blue vh-100 position-fixed"
            style={{ width: '250px', zIndex: '200' }}
        >
            <div className="mx-auto">
                <Link to="/" className="p-2 text-decoration-none">
                    <img src={stiLogo} alt="Logo" width="40" height="40" className='my-2' />
                </Link>
            </div>

            <ul className="list-unstyled p-3">
                <li className="mb-3">
                    <i className="bi bi-border-style me-2 text-white"></i>
                    <Link to={`${basePath}/dashboard`} className='text-decoration-none text-white'>Dashboard</Link>
                </li>
                <li className="mb-3">
                    <i className="bi bi-book me-2 text-white"></i>
                    <Link to={`${basePath}/modules`} className='text-decoration-none text-white'>Modules</Link>
                </li>
                <li className="mb-3">
                    <i className="bi bi-file-earmark-text me-2 text-white"></i>
                    <Link to={`${basePath}/assessments`} className='text-decoration-none text-white'>Assessments</Link>
                </li>
                <li className="mb-3">
                    <i className="bi bi-trophy me-2 text-white"></i>
                    <Link to={`${basePath}/achievements`} className='text-decoration-none text-white'>Achievements</Link>
                </li>
                <li className="mb-3">
                    <i className="bi bi-list-ul me-2 text-white"></i>
                    <Link to={`${basePath}/sections`} className='text-decoration-none text-white'>Sections</Link>
                </li>

                {!currentUser?.isTeacher && (
                    <li>
                        <i className="bi bi-people me-2 text-white"></i>
                        <Link to={`${basePath}/users`} className='text-decoration-none text-white'>Users</Link>
                    </li>
                )}
            </ul>
        </div>
    );
}

export default AdminSidebar;

