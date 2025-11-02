import React, { useState, useEffect } from 'react';
import { Table, Button, Form, Pagination } from 'react-bootstrap';
import { deleteAssessment, getAssessments } from '../../services/assessmentsService';
import { getModules } from '../../services/modulesService';
import DeleteModal from '../modals/DeleteModal';
import CreateEditAssessmentModal from '../modals/CreateEditAssessment';
import Loading from '../Loading';


const AssessmentsTable = () => {
    const [assessments, setAssessments] = useState([]);
    const [modules, setModules] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [loading, setLoading] = useState(false);

    const [showEditModal, setShowEditModal] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [selectedAssessment, setSelectedAssessment] = useState(null);

    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;

    const filteredAssessments = assessments.filter((assessment) =>
        assessment.module.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const selectedAssessments = filteredAssessments.slice(indexOfFirstItem, indexOfLastItem);
    const totalPages = Math.ceil(filteredAssessments.length / itemsPerPage);

    useEffect(() => {
        fetchAssessments();
        fetchModules();
    }, []);


    const handleSearch = (event) => {
        setSearchTerm(event.target.value);
        setCurrentPage(1);
    };

    const fetchAssessments = async () => {
        setLoading(true);
        try {
            const response = await getAssessments();
            setAssessments(response);
        } catch (error) {
            console.error('Error fetching achievements:', error);
        } finally {
            setLoading(false);
        }
    };

    const fetchModules = async () => {
        setLoading(true);
        try {
            const response = await getModules();
            setModules(response);
        } catch (error) {
            console.error('Error fetching achievements:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = () => {
        setSelectedAssessment(null);
        setShowEditModal(true);
    };

    const handleUpdate = () => {
        fetchAssessments();
    };

    const handleClose = () => {
        setShowEditModal(false);
        setShowDeleteModal(false);
        setSelectedAssessment(null);
    };

    const handleEdit = (id) => {
        const assessmentToEdit = assessments.find((assess) => assess.id === id);
        setSelectedAssessment(assessmentToEdit);
        setShowEditModal(true);
    };

    const handlePageChange = (direction) => {
        if (direction === "next" && currentPage < totalPages) {
            setCurrentPage((prev) => prev + 1);
        } else if (direction === "prev" && currentPage > 1) {
            setCurrentPage((prev) => prev - 1);
        }
    };

    const handleDelete = (assessment) => {
        const assessmentToDelete = assessments.find((assess) => assess.id === assessment.id);
        setSelectedAssessment(assessment);
        setShowDeleteModal(true);
    };

    const confirmDelete = () => {
        setShowDeleteModal(false);
    };

    return (
        <div className="container my-4">
            <div className="d-flex justify-content-end py-2">
                <Button variant="primary" size="sm" onClick={handleCreate}>
                    <i className="bi bi-plus text-white me-2"></i>
                    Add Assessment
                </Button>
            </div>
            <div className="d-flex justify-content-between align-items-center mb-3">
                <span className="fs-5 fw-bold">Assessments</span>
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
                    <Table bordered hover responsive>
                        <thead>
                            <tr>
                                <th>Module No.</th>
                                <th>Module Title</th>
                                <th>Number of Questions</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {selectedAssessments.map((assessment) => (
                                <tr key={assessment.id}>
                                    <td>
                                        {modules.find(mod => mod.title === assessment.module)?.moduleNumber}
                                    </td>
                                    <td>{assessment.module}</td>
                                    <td>{assessment.questions.length}</td>
                                    <td>
                                        <div className="d-flex">
                                            <Button
                                                variant="primary"
                                                size="sm"
                                                className="me-2"
                                                onClick={() => handleEdit(assessment.id)}
                                            >
                                                <i className="bi bi-pencil text-white"></i>
                                            </Button>
                                            <Button
                                                variant="danger"
                                                size="sm"
                                                onClick={() => handleDelete(assessment)}
                                            >
                                                <i className="bi bi-trash text-white"></i>
                                            </Button>
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </Table>

                    {/* Pagination */}
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

                    <CreateEditAssessmentModal
                        show={showEditModal}
                        handleClose={handleClose}
                        assessment={selectedAssessment}
                        onUpdate={handleUpdate}
                        modules={modules}
                    />

                    {/* Delete Modal */}
                    {showDeleteModal && (
                        <DeleteModal
                            show={showDeleteModal}
                            handleClose={() => setShowDeleteModal(false)}
                            handleConfirm={confirmDelete}
                            message={`Are you sure you want to delete the assessment for "${selectedAssessment?.module}"?`}
                        />
                    )}
                </div>
            }

        </div>
    );
};

export default AssessmentsTable;
