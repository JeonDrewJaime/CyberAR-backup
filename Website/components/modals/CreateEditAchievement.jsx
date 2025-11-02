import React, { useEffect } from 'react';
import { Modal, Form, Button } from 'react-bootstrap';
import { Formik } from 'formik';
import * as Yup from 'yup';
import { createAchievement, editAchievement } from '../../services/achievementsService';

const validationSchema = Yup.object().shape({
    title: Yup.string().required('Title is required'),
    description: Yup.string().required('Description is required'),
});

const CreateEditAchievementModal = ({ show, handleClose, achievement, onUpdate }) => {
    const initialValues = {
        title: achievement?.title || '',
        description: achievement?.description || '',
    };

    const handleSubmit = async (values, { setSubmitting }) => {
        try {
            const achievementData = {
                title: values.title,
                description: values.description,
            };

            if (achievement && achievement.id) {
                await editAchievement(achievement.id, achievementData);
            } else {
                await createAchievement(achievementData);
            }

            onUpdate();
            handleClose();
        } catch (error) {
            console.error('Failed to save achievement', error);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <Modal show={show} onHide={handleClose}>
            <Modal.Header closeButton>
                <Modal.Title>{achievement ? 'Edit Achievement' : 'Create Achievement'}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Formik
                    initialValues={initialValues}
                    validationSchema={validationSchema}
                    onSubmit={handleSubmit}
                >
                    {({
                        values,
                        errors,
                        touched,
                        handleChange,
                        setFieldValue,
                        handleBlur,
                        handleSubmit,
                        isSubmitting,
                    }) => (
                        <Form noValidate onSubmit={handleSubmit}>
                            <Form.Group controlId="formTitle">
                                <Form.Label>Title</Form.Label>
                                <Form.Control
                                    type="text"
                                    name="title"
                                    value={values.title}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.title && !!errors.title}
                                    placeholder="Enter achievement title"
                                />
                                <Form.Control.Feedback type="invalid">
                                    {errors.title}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group controlId="formDescription" className="mt-3">
                                <Form.Label>Description</Form.Label>
                                <Form.Control
                                    as="textarea"
                                    rows={3}
                                    name="description"
                                    value={values.description}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.description && !!errors.description}
                                    placeholder="Enter achievement description"
                                />
                                <Form.Control.Feedback type="invalid">
                                    {errors.description}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <div className="mt-4 d-flex justify-content-end">
                                <Button variant="secondary" onClick={handleClose} disabled={isSubmitting}>
                                    Cancel
                                </Button>
                                <Button
                                    variant="primary"
                                    type="submit"
                                    className="ms-2"
                                    disabled={isSubmitting}
                                >
                                    {achievement ? 'Update' : 'Create'}
                                </Button>
                            </div>
                        </Form>
                    )}
                </Formik>
            </Modal.Body>
        </Modal>
    );
};

export default CreateEditAchievementModal;
