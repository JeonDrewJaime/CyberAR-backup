import { useState, useEffect } from 'react';
import { Modal, Button, Form, InputGroup } from 'react-bootstrap';
import { Formik } from 'formik';
import * as Yup from 'yup';
import { createSection, editSection } from '../../services/sectionsService';

const validationSchema = Yup.object().shape({
    name: Yup.string().required('Section name is required'),
    year: Yup.string().required('Year level is required'),
    department: Yup.string().required('Department is required'),
});

const CreateEditSection = ({ show, handleClose, section, onUpdate }) => {
    const initialValues = {
        name: '',
        year: '',
        department: '',
    };

    useEffect(() => { }, [section]);

    const handleSubmit = async (values, { setSubmitting }) => {
        try {
            if (section && section.id) {
                await editSection(section.id, values);
            } else {
                await createSection(values);
            }

            onUpdate();
            handleClose();
        } catch (error) {
            console.error('Failed to update section', error);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <Modal show={show} onHide={handleClose}>
            <Modal.Header closeButton>
                <Modal.Title>{section ? 'Edit Section' : 'Create Section'}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Formik initialValues={initialValues} validationSchema={validationSchema} onSubmit={handleSubmit}>
                    {({ values, errors, touched, handleChange, handleBlur, handleSubmit, isSubmitting }) => (
                        <Form noValidate onSubmit={handleSubmit}>
                            <Form.Group className="mb-3" controlId="name">
                                <Form.Label>Section Name</Form.Label>
                                <Form.Control type="text" name="name" value={values.name} onChange={handleChange} onBlur={handleBlur} isInvalid={touched.name && !!errors.name} />
                                <Form.Control.Feedback type="invalid">{errors.name}</Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group className="mb-3" controlId="year">
                                <Form.Label>Year Level</Form.Label>
                                <Form.Control type="text" name="year" value={values.year} onChange={handleChange} onBlur={handleBlur} isInvalid={touched.year && !!errors.year} />
                                <Form.Control.Feedback type="invalid">{errors.year}</Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group className="mb-3" controlId="department">
                                <Form.Label>Department</Form.Label>
                                <Form.Control type="text" name="department" value={values.department} onChange={handleChange} onBlur={handleBlur} isInvalid={touched.department && !!errors.department} />
                                <Form.Control.Feedback type="invalid">{errors.department}</Form.Control.Feedback>
                            </Form.Group>
                            <Button variant="primary" type="submit" disabled={isSubmitting}>
                                {section ? 'Update' : 'Create'}
                            </Button>
                        </Form>
                    )}
                </Formik>
            </Modal.Body>
        </Modal>
    )
}

export default CreateEditSection
