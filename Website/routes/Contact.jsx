import React, { useState } from 'react';
import { Form, Button, Card, Alert, Container, Row, Col } from 'react-bootstrap';
import { Formik } from 'formik';
import * as Yup from 'yup';
import Header from '../components/Header';
import contact from '../assets/contact.png';


export const Contact = () => {
    const [submitError, setSubmitError] = useState('');

    const validationSchema = Yup.object().shape({
        name: Yup.string().required('Name is required'),
        email: Yup.string().email('Invalid email address').required('Email is required'),
        message: Yup.string().min(10, 'Message must be at least 10 characters').required('Message is required'),
    });

    const handleSubmit = (values, { setSubmitting, setErrors }) => {
        setSubmitError('');

        try {
            setTimeout(() => {
                setSubmitting(false);
            }, 1000);
        } catch (error) {
            setSubmitError('There was an error submitting your message.');
            setSubmitting(false);
        }
    };

    return (
        <div>
            <Header />
            <Container className='mt-4'>
                <Row className="d-flex justify-content-center align-items-center" style={{ minHeight: '80vh' }}>
                    <Col lg={6} className='d-none d-lg-block'>
                        <img src={contact} alt="CyberQuest" className="img-fluid" />
                    </Col>
                    <Col lg={6}>
                        <Card className="px-3 py-4">
                            <Card.Title className="text-center mb-4 fs-2">Contact Us</Card.Title>
                            <p className='text-center'>If you have any questions or feedback, feel free to reach out to us!</p>
                            <Card.Body>
                                <Formik
                                    initialValues={{ name: '', email: '', message: '' }}
                                    validationSchema={validationSchema}
                                    onSubmit={handleSubmit}
                                >
                                    {({
                                        handleSubmit,
                                        handleChange,
                                        values,
                                        touched,
                                        errors,
                                        isSubmitting,
                                    }) => (
                                        <Form noValidate onSubmit={handleSubmit}>
                                            {/* Name Field */}
                                            <Form.Group controlId="formName" className="mb-3">
                                                <Form.Label>Name</Form.Label>
                                                <Form.Control
                                                    type="text"
                                                    name="name"
                                                    placeholder="Enter your name"
                                                    value={values.name}
                                                    onChange={handleChange}
                                                    isInvalid={touched.name && !!errors.name}
                                                />
                                                <Form.Control.Feedback type="invalid">
                                                    {errors.name}
                                                </Form.Control.Feedback>
                                            </Form.Group>

                                            {/* Email Field */}
                                            <Form.Group controlId="formEmail" className="mb-3">
                                                <Form.Label>Email</Form.Label>
                                                <Form.Control
                                                    type="email"
                                                    name="email"
                                                    placeholder="Enter your email"
                                                    value={values.email}
                                                    onChange={handleChange}
                                                    isInvalid={touched.email && !!errors.email}
                                                />
                                                <Form.Control.Feedback type="invalid">
                                                    {errors.email}
                                                </Form.Control.Feedback>
                                            </Form.Group>

                                            {/* Message Field */}
                                            <Form.Group controlId="formMessage" className="mb-3">
                                                <Form.Label>Message</Form.Label>
                                                <Form.Control
                                                    as="textarea"
                                                    rows={4}
                                                    name="message"
                                                    placeholder="Enter your message"
                                                    value={values.message}
                                                    onChange={handleChange}
                                                    isInvalid={touched.message && !!errors.message}
                                                />
                                                <Form.Control.Feedback type="invalid">
                                                    {errors.message}
                                                </Form.Control.Feedback>
                                            </Form.Group>

                                            {/* Error or Success Message */}
                                            {submitError && (
                                                <Alert variant="danger" className="mb-3">
                                                    {submitError}
                                                </Alert>
                                            )}

                                            {/* Submit Button */}
                                            <Button
                                                variant="primary"
                                                type="submit"
                                                className="w-100"
                                                disabled={isSubmitting}
                                            >
                                                {isSubmitting ? 'SUBMITTING...' : 'SUBMIT'}
                                            </Button>
                                        </Form>
                                    )}
                                </Formik>
                            </Card.Body>
                        </Card>
                    </Col>

                </Row>
            </Container>
        </div>
    );
};
