import { useState, useEffect } from 'react';
import { Table, Form, Button, Pagination } from 'react-bootstrap';
import { deleteSection, getSections } from '../../services/sectionsService';
import CreateEditSection from '../modals/CreateEditSection';
import DeleteModal from '../modals/DeleteModal';
import Loading from '../Loading';

const SectionsTable = () => {
    const [sections, setSections] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [loading, setLoading] = useState(false);

    const [showEditModal, setShowEditModal] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [selectedSection, setSelectedSection] = useState(null);
    const itemsPerPage = 5;

    useEffect(() => {
        fetchSections();
    }, []);

    // Filtered data based on search term
    const filteredData = sections.filter((section) => {
        return section.name.toLowerCase().includes(searchTerm.toLowerCase());
    });

    // Pagination calculation
    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentSections = filteredData.slice(indexOfFirstItem, indexOfLastItem);

    const totalPages = Math.ceil(filteredData.length / itemsPerPage);

    const fetchSections = async () => {
        setLoading(true);
        try {
            const response = await getSections();
            setSections(response);
        } catch (error) {
            console.error('Failed to fetch sections', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSearch = (event) => {
        setSearchTerm(event.target.value);
        setCurrentPage(1);
    };

    const handleCreate = () => {
        setSelectedSection(null);
        setShowEditModal(true);
    }

    const handleEdit = (id) => {
        const sectionToEdit = sections.find(ann => ann.id === id);
        setSelectedSection(sectionToEdit);
        setShowEditModal(true);
    };

    const handleUpdate = () => {
        fetchSections();
    };

    const handleClose = () => {
        setShowEditModal(false);
        setShowDeleteModal(false);
        setSelectedSection(null);
    };

    const handleDelete = async (id) => {
        const sectionToDelete = sections.find(ann => ann.id === id);
        setSelectedSection(sectionToDelete);
        setShowDeleteModal(true);
    }

    const confirmDelete = async (id) => {
        try {
            await deleteSection(id);
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
                <Button variant="primary" size="sm" className="me-2" onClick={() => handleCreate()}>
                    <i className="bi bi-plus text-white me-2"></i>
                    Add Section
                </Button>
            </div>
            <div className="d-flex justify-content-between align-items-center mb-3">
                <span className="fs-5 fw-bold">Sections</span>
                <Form.Control
                    type="text"
                    placeholder="Search by section name"
                    value={searchTerm}
                    onChange={handleSearch}
                    style={{ maxWidth: '300px' }}
                />
            </div>
            {loading ? (
                <Loading />
            ) : (
                <>
                    <Table striped bordered hover>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Year</th>
                                <th>Department</th>
                                <th>No. of Students</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {currentSections.map((section) => (
                                <tr key={section.id}>
                                    <td>{section.name}</td>
                                    <td>{section.year}</td>
                                    <td>{section.department}</td>
                                    <td>{section.totalStudents}</td>
                                    <td>
                                        <div className="d-flex">
                                            <Button
                                                variant="primary"
                                                size="sm"
                                                className="me-2"
                                                onClick={() => handleEdit(section.id)}
                                            >
                                                <i className="bi bi-pencil text-white"></i>
                                            </Button>
                                            <Button
                                                variant="danger"
                                                size="sm"
                                                onClick={() => handleDelete(section.id)}
                                            >
                                                <i className="bi bi-trash text-white"></i>
                                            </Button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </Table>
                    <Pagination>
                        <Pagination.Prev
                            onClick={() => handlePageChange("prev")}
                        />
                        <Pagination.Item>{currentPage}</Pagination.Item>
                        <Pagination.Next
                            onClick={() => handlePageChange("next")}
                        />
                    </Pagination>
                </>
            )}
            <CreateEditSection
                show={showEditModal}
                handleClose={handleClose}
                section={selectedSection}
                onUpdate={handleUpdate}
            />
            <DeleteModal
                show={showDeleteModal}
                handleClose={handleClose}
                item={selectedSection}
                onDelete={confirmDelete}
            />

        </div>
    )
}

export default SectionsTable
