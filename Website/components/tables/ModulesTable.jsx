import { useState, useEffect } from 'react';
import { Table, Form, Button, Pagination } from 'react-bootstrap';
import { deleteModule, getModules } from '../../services/modulesService';
import DeleteModal from '../modals/DeleteModal';
import CreateEditModuleModal from '../modals/CreateEditModule';
import Loading from '../Loading';


const ModulesTable = () => {
    const [modules, setModules] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [loading, setLoading] = useState(false);

    const [showEditModal, setShowEditModal] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [selectedModule, setSelectedModule] = useState(null);
    const itemsPerPage = 5;

    useEffect(() => {
        fetchModules();
    }, []);

    // Filtered data based on search term
    const filteredModules = modules.filter(module =>
        module.title.toLowerCase().includes(searchTerm.toLowerCase())
    );

    // Pagination calculation
    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentModules = filteredModules.slice(indexOfFirstItem, indexOfLastItem);

    const totalPages = Math.ceil(filteredModules.length / itemsPerPage);

    const handleSearch = (event) => {
        setSearchTerm(event.target.value);
        setCurrentPage(1);
    };

    const fetchModules = async () => {
        setLoading(true);
        try {
            const response = await getModules();
            setModules(response);
        } catch (error) {
            console.error('Error fetching modules:', error);
        } finally { setLoading(false); }
    };

    const handleCreate = () => {
        setSelectedModule(null);
        setShowEditModal(true);
    };

    const handleEdit = (id) => {
        const moduleToEdit = modules.find(mod => mod.id === id);
        setSelectedModule(moduleToEdit);
        setShowEditModal(true);
    };

    const handleUpdate = () => {
        fetchModules();
    };

    const handleClose = () => {
        setShowEditModal(false);
        setShowDeleteModal(false);
        setSelectedModule(null);
    };

    const handleDelete = async (id) => {
        const moduleToDelete = modules.find(mod => mod.id === id);
        setSelectedModule(moduleToDelete);
        setShowDeleteModal(true);
    };

    const confirmDelete = async (id) => {
        try {
            await deleteModule(id);
            handleUpdate();
            handleClose();
        } catch (error) {
            console.error('Error deleting module:', error);
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
                <Button variant="primary" size="sm" className="me-2" onClick={() => handleCreate()}>
                    <i className="bi bi-plus text-white me-2"></i>
                    Add Module
                </Button>
            </div>
            <div className="d-flex justify-content-between align-items-center mb-3">
                <span className="fs-5 fw-bold">Modules</span>
                <Form.Control
                    type="text"
                    placeholder="Search by title"
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
                                <th>Module No.</th>
                                <th>Title</th>
                                <th>Description</th>
                                <th>Number of Lessons</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {currentModules.map((module) => (
                                <tr key={module.id}>
                                    <td>{module.moduleNumber}</td>
                                    <td>{module.title}</td>
                                    <td>{module.description}</td>
                                    <td>{module.lessons.length}</td>
                                    <td>
                                        <div className="d-flex">
                                            <Button
                                                variant="primary"
                                                size="sm"
                                                className="me-2"
                                                onClick={() => handleEdit(module.id)}
                                            >
                                                <i className="bi bi-pencil text-white"></i>
                                            </Button>
                                            <Button
                                                variant="danger"
                                                size="sm"
                                                onClick={() => handleDelete(module.id)}
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

                    <CreateEditModuleModal
                        show={showEditModal}
                        handleClose={handleClose}
                        module={selectedModule}
                        onUpdate={handleUpdate}
                    />
                    <DeleteModal
                        show={showDeleteModal}
                        handleClose={() => setShowDeleteModal(false)}
                        handleDelete={() => confirmDelete(selectedModule.id)}
                        title="Delete Module"
                        message="Are you sure you want to delete this module?"
                    />
                </div>
            }
        </div>
    );
};

export default ModulesTable;
