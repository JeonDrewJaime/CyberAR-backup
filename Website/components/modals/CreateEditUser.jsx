import { useState, useEffect } from 'react';
import { Modal, Button, Form, InputGroup } from 'react-bootstrap';
import { Formik } from 'formik';
import * as Yup from 'yup';
import { createUser, editUser } from '../../services/usersService';

const validationSchema = Yup.object().shape({
    name: Yup.string().required('Name is required'),
    studentNumber: Yup.number().required('Student Number is required').typeError('Student Number is invalid'),
    section: Yup.string().required('Section is required'),
    email: Yup.string().required('Email is required'),
    password: Yup.string().required('Password is required'),
});

const CreateEditUserModal = ({ show, handleClose, user, sections, onUpdate }) => {
    const [errorMessage, setErrorMessage] = useState('');
    
    const initialValues = {
        name: user?.name || '',
        studentNumber: user?.studentNumber || '',
        section: user?.section || '',
        email: user?.email || '',
        password: user?.password || '',
    };

    useEffect(() => {
        setErrorMessage(''); // Clear error when modal opens/closes or user changes
    }, [user, show]);

    const handleSubmit = async (values, { setSubmitting }) => {
        setErrorMessage('');
        try {
            if (user && user.id) {
                await editUser(user.id, values);
            } else {
                values.email = `${values.email}@caloocan.sti.edu.ph`.toLowerCase();
                await createUser(values);
            }

            onUpdate();
            handleClose();
        } catch (error) {
            console.error('Failed to update user', error);
            setErrorMessage(error.message || 'Failed to create user. Please try again.');
        } finally {
            setSubmitting(false);
        }
    };

    const [showPassword, setShowPassword] = useState(false);

    const togglePasswordVisibility = () => {
        setShowPassword((prev) => !prev);
    };

    return (
        <Modal show={show} onHide={handleClose}>
            <Modal.Header closeButton>
                <Modal.Title>{user ? 'Edit User' : 'Create User'}</Modal.Title>
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
                        handleBlur,
                        handleSubmit,
                        isSubmitting,
                    }) => (
                        <Form noValidate onSubmit={handleSubmit}>
                            <Form.Group controlId="formName">
                                <Form.Label>Name</Form.Label>
                                <Form.Control
                                    type="text"
                                    name="name"
                                    value={values.name}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.name && errors.name}
                                    placeholder="Enter user name"
                                />
                                <Form.Control.Feedback type="invalid">
                                    {errors.name}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group controlId="formStudentNumber" className="mt-3">
                                <Form.Label>Student Number</Form.Label>
                                <Form.Control
                                    type="text"
                                    name="studentNumber"
                                    value={values.studentNumber}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.studentNumber && errors.studentNumber}
                                    placeholder="Enter student number"
                                />
                                <Form.Control.Feedback type="invalid">
                                    {errors.studentNumber}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group controlId="formSection" className="mt-3">
                                <Form.Label>Section</Form.Label>
                                <Form.Control
                                    as="select"
                                    name="section"
                                    value={values.section}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.section && errors.section}
                                >
                                    <option value="">Select Section</option>
                                    {sections.map((section) => (
                                        <option key={section.id} value={section.name}>
                                            Year {section.year}: {section.name}
                                        </option>
                                    ))}
                                </Form.Control>
                                <Form.Control.Feedback type="invalid">
                                    {errors.section}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group controlId="formEmail" className="mt-3">
                                <Form.Label>Email</Form.Label>
                                <InputGroup>
                                    <Form.Control
                                        type="text"
                                        name="email"
                                        value={values.email}
                                        onChange={handleChange}
                                        onBlur={handleBlur}
                                        isInvalid={touched.email && errors.email}
                                        placeholder="Enter user email"
                                    />
                                    {
                                        !user && <InputGroup.Text>@caloocan.sti.edu.ph</InputGroup.Text>
                                    }
                                </InputGroup>
                                <Form.Control.Feedback type="invalid">
                                    {errors.email}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group controlId="formPassword" className="mt-3">
                                <Form.Label>{user ? "Change Password" : "Password"}</Form.Label>
                                <div className="input-group">
                                    <Form.Control
                                        type={showPassword ? "text" : "password"}
                                        name="password"
                                        value={values.password}
                                        onChange={handleChange}
                                        onBlur={handleBlur}
                                        isInvalid={touched.password && errors.password}
                                        placeholder="Enter user password"
                                    />
                                    <button
                                        type="button"
                                        className="input-group-text bg-white border-0"
                                        onClick={togglePasswordVisibility}
                                    >
                                        <i className={`bi ${showPassword ? "bi-eye-slash" : "bi-eye"}`}></i>
                                    </button>
                                    <Form.Control.Feedback type="invalid">
                                        {errors.password}
                                    </Form.Control.Feedback>
                                </div>
                            </Form.Group>
                            {errorMessage && (
                                <div className="alert alert-danger mt-3" role="alert">
                                    {errorMessage}
                                </div>
                            )}
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
                                    {user ? 'Update' : 'Create'}
                                </Button>
                            </div>
                        </Form>
                    )}
                </Formik>
            </Modal.Body>
        </Modal>
    );
};

export default CreateEditUserModal;
