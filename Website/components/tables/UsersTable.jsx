import { useState, useEffect } from 'react';
import { Table, Form, Button, Pagination } from 'react-bootstrap';
import { deleteUser, getUsers } from '../../services/usersService';
import CreateEditUserModal from '../modals/CreateEditUser';
import CreateEditTeacherModal from '../modals/CreateEditTeacher';
import DeleteModal from '../modals/DeleteModal';
import Loading from '../Loading';
import { getSections } from '../../services/sectionsService';

const UsersTable = () => {
    const [users, setUsers] = useState([]);
    const [sections, setSections] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [loading, setLoading] = useState(false);

    const [showEditModal, setShowEditModal] = useState(false);
    const [showTeacherEditModal, setShowTeacherEditModal] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [selectedUser, setSelectedUser] = useState(null);
    const itemsPerPage = 5;

    useEffect(() => {
        fetchUsers();
        fetchSections();
    }, []);

    // Filtered data based on search term
    const filteredUsers = users.filter(users =>
        users.name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    // Pagination calculation
    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentUsers = filteredUsers.slice(indexOfFirstItem, indexOfLastItem);

    const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);

    const handleSearch = (event) => {
        setSearchTerm(event.target.value);
        setCurrentPage(1);
    };

    const fetchUsers = async () => {
        setLoading(true);
        try {
            const response = await getUsers();
            setUsers(response);
        } catch (error) {
            console.error('Error fetching users:', error);
        } finally { setLoading(false); }
    }

    const fetchSections = async () => {
        try {
            const response = await getSections();
            setSections(response);
        } catch (error) {
            console.error('Error fetching sections:', error);
        } finally { setLoading(false); }
    }

    const handleCreate = () => {
        setSelectedUser(null);
        setShowEditModal(true);
    }

    const handleCreateTeacher = () => {
        setSelectedUser(null);
        setShowTeacherEditModal(true);
    }

    const handleEdit = (id) => {
        const userToEdit = users.find(ann => ann.id === id);
        setSelectedUser(userToEdit);
        setShowEditModal(true);
    };

    const handleUpdate = () => {
        fetchUsers();
    };

    const handleClose = () => {
        setShowEditModal(false);
        setShowTeacherEditModal(false);
        setShowDeleteModal(false);
        setSelectedUser(null);
    };

    const handleDelete = async (id) => {
        const userToDelete = users.find(ann => ann.id === id);
        setSelectedUser(userToDelete);
        setShowDeleteModal(true);
    }

    const confirmDelete = async (id) => {
        try {
            await deleteUser(id);
            handleUpdate();
            handleClose();
        } catch (error) {
            console.error('Error deleting announcement:', error);
        }
    };

    const handlePageChange = (direction) => {
        if (direction === "next" && currentPage < totalPages) {
            setCurrentPage((prev) => prev + 1);
        } else if (direction === "prev" && currentPage > 1) {
            setCurrentPage((prev) => prev - 1);
        }
    };

    return (
        <div className="container my-4">
            <div className="d-flex justify-content-end py-2">
                <Button variant="primary" size="sm" className="me-2" onClick={() => handleCreateTeacher()}>
                    <i className="bi bi-plus text-white me-2"></i>
                    Add Teacher
                </Button>
                <Button variant="primary" size="sm" onClick={() => handleCreate()}>
                    <i className="bi bi-plus text-white me-2"></i>
                    Add User
                </Button>
            </div>
            <div className="d-flex justify-content-between align-items-center mb-3">
                <span className="fs-5 fw-bold">Users</span>
                <Form.Control
                    type="text"
                    placeholder="Search by name"
                    value={searchTerm}
                    onChange={handleSearch}
                    style={{ maxWidth: '300px' }}
                />
            </div>
            {loading && <Loading />}
            {
                !loading && <div>
                    <Table bordered hover>
                        <thead>
                            <tr>
                                <th>Student No.</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Section</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {currentUsers.map((user) => (
                                <tr key={user.id}>
                                    <td>{user.studentNumber ?? 'N/A'}</td>
                                    <td>{user.name}</td>
                                    <td>{user.email}</td>
                                    <td>{user.section ?? 'N/A'}</td>
                                    <td>
                                        <div className="d-flex">
                                            <Button
                                                variant="primary"
                                                size="sm"
                                                className="me-2"
                                                onClick={() => handleEdit(user.id)}
                                            >
                                                <i className="bi bi-pencil text-white"></i>
                                            </Button>
                                            <Button
                                                variant="danger"
                                                size="sm"
                                                onClick={() => handleDelete(user.id)}
                                            >
                                                <i className="bi bi-trash text-white"></i>
                                            </Button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>

                    </Table>

                    <Pagination className="justify-content-center mt-4">
                        <Pagination.Prev
                            disabled={currentPage === 1}
                            onClick={() => handlePageChange("prev")}
                        />
                        <Pagination.Item active>{currentPage}</Pagination.Item>
                        <Pagination.Next
                            disabled={currentPage === totalPages}
                            onClick={() => handlePageChange("next")}
                        />
                    </Pagination>

                    <CreateEditUserModal
                        show={showEditModal}
                        handleClose={handleClose}
                        user={selectedUser}
                        sections={sections}
                        onUpdate={handleUpdate}
                    />

                    <CreateEditTeacherModal
                        show={showTeacherEditModal}
                        handleClose={handleClose}
                        user={selectedUser}
                        onUpdate={handleUpdate}
                    />

                    <DeleteModal
                        show={showDeleteModal}
                        handleClose={() => setShowDeleteModal(false)}
                        handleDelete={() => confirmDelete(selectedUser.id)}
                        title="Delete User"
                        message="Are you sure you want to delete this user?"
                    />
                </div>
            }
        </div>
    );
};

export default UsersTable;
