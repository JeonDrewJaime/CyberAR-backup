import React, { useEffect, useState } from 'react';
import { Table, Button, Form, Pagination } from 'react-bootstrap';
import { getAchievements, deleteAchievement } from '../../services/achievementsService';
import CreateEditAchievementModal from '../modals/CreateEditAchievement';
import DeleteModal from '../modals/DeleteModal';
import Loading from '../Loading';

const AchievementsTable = () => {
    const [achievements, setAchievements] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(1);
    const [loading, setLoading] = useState(false);

    const [showEditModal, setShowEditModal] = useState(false);
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [selectedAchievement, setSelectedAchievement] = useState(null);
    const itemsPerPage = 5;

    useEffect(() => {
        fetchAchievements();
    }, []);

    const filteredAchievements = achievements.filter((achievement) =>
        achievement.title.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentAchievements = filteredAchievements.slice(indexOfFirstItem, indexOfLastItem);

    const totalPages = Math.ceil(filteredAchievements.length / itemsPerPage);

    const handleSearch = (event) => {
        setSearchTerm(event.target.value);
        setCurrentPage(1);
    };

    const fetchAchievements = async () => {
        setLoading(true);
        try {
            const response = await getAchievements();
            setAchievements(response);
        } catch (error) {
            console.error('Error fetching achievements:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = () => {
        setSelectedAchievement(null);
        setShowEditModal(true);
    };

    const handleEdit = (id) => {
        const achievementToEdit = achievements.find((ach) => ach.id === id);
        setSelectedAchievement(achievementToEdit);
        setShowEditModal(true);
    };

    const handleUpdate = () => {
        fetchAchievements();
    };

    const handleClose = () => {
        setShowEditModal(false);
        setShowDeleteModal(false);
        setSelectedAchievement(null);
    };

    const handleDelete = (id) => {
        const achievementToDelete = achievements.find((ach) => ach.id === id);
        setSelectedAchievement(achievementToDelete);
        setShowDeleteModal(true);
    };

    const confirmDelete = async (id) => {
        try {
            await deleteAchievement(id);
            handleUpdate();
            handleClose();
        } catch (error) {
            console.error('Error deleting achievement:', error);
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
                <Button variant="primary" size="sm" onClick={handleCreate}>
                    <i className="bi bi-plus text-white me-2"></i>
                    Add Achievement
                </Button>
            </div>
            <div className="d-flex justify-content-between align-items-center mb-3">
                <span className="fs-5 fw-bold">Achievements</span>
                <Form.Control
                    type="text"
                    placeholder="Search by title"
                    value={searchTerm}
                    onChange={handleSearch}
                    style={{ maxWidth: '300px' }}
                />
            </div>
            {loading && <Loading />}
            {!loading && (
                <div>
                    <Table bordered hover>
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Description</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {currentAchievements.map((achievement) => (
                                <tr key={achievement.id}>
                                    <td>{achievement.title}</td>
                                    <td>{achievement.description}</td>
                                    <td>
                                        <div className="d-flex">
                                            <Button
                                                variant="primary"
                                                size="sm"
                                                className="me-2"
                                                onClick={() => handleEdit(achievement.id)}
                                            >
                                                <i className="bi bi-pencil text-white"></i>
                                            </Button>
                                            <Button
                                                variant="danger"
                                                size="sm"
                                                onClick={() => handleDelete(achievement.id)}
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

                    <CreateEditAchievementModal
                        show={showEditModal}
                        handleClose={handleClose}
                        achievement={selectedAchievement}
                        onUpdate={handleUpdate}
                    />
                    <DeleteModal
                        show={showDeleteModal}
                        handleClose={() => setShowDeleteModal(false)}
                        handleDelete={() => confirmDelete(selectedAchievement.id)}
                        title="Delete Achievement"
                        message="Are you sure you want to delete this achievement?"
                    />
                </div>
            )}
        </div>
    );
};

export default AchievementsTable;
