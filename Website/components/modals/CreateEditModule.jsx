import { useState } from 'react';
import { Modal, Button, Form, InputGroup } from 'react-bootstrap';
import { Formik, FieldArray } from 'formik';
import * as Yup from 'yup';
import { createModule, editModule } from '../../services/modulesService';

const validationSchema = Yup.object().shape({
    moduleNumber: Yup.number().required('Module number is required').typeError('Module number must be a number'),
    title: Yup.string().required('Title is required'),
    description: Yup.string().required('Description is required'),
    lessons: Yup.array().of(
        Yup.object().shape({
            title: Yup.string().required('Lesson title is required'),
            content: Yup.string().required('Lesson content is required'),
        })
    ),
});

const CreateEditModuleModal = ({ show, handleClose, module, onUpdate }) => {
    const initialValues = {
        moduleNumber: module?.moduleNumber || '',
        title: module?.title || '',
        description: module?.description || '',
        lessons: module?.lessons || [{ title: '', content: '', id: 1 }],
    };

    const handleSubmit = async (values, { setSubmitting }) => {
        try {
            if (module && module.id !== null) {
                await editModule(module.id, values);
            } else {
                await createModule(values);
            }

            onUpdate(values);
            handleClose();
        } catch (error) {
            console.error('Failed to save module:', error);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <Modal show={show} onHide={handleClose} size="lg">
            <Modal.Header closeButton>
                <Modal.Title>{module ? 'Edit Module' : 'Create Module'}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Formik
                    initialValues={initialValues}
                    validationSchema={validationSchema}
                    onSubmit={handleSubmit}
                >
                    {({ values, errors, touched, handleChange, handleBlur, handleSubmit, isSubmitting }) => (
                        <Form noValidate onSubmit={handleSubmit}>
                            <Form.Group controlId="formModuleNumber">
                                <Form.Label>Module Number</Form.Label>
                                <Form.Control
                                    type="text"
                                    name="moduleNumber"
                                    value={values.moduleNumber}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.moduleNumber && errors.moduleNumber}
                                    placeholder="Enter module number"
                                />
                                <Form.Control.Feedback type="invalid">
                                    {errors.moduleNumber}
                                </Form.Control.Feedback>
                            </Form.Group>

                            <Form.Group controlId="formTitle" className="mt-3">
                                <Form.Label>Title</Form.Label>
                                <Form.Control
                                    type="text"
                                    name="title"
                                    value={values.title}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.title && errors.title}
                                    placeholder="Enter module title"
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
                                    isInvalid={touched.description && errors.description}
                                    placeholder="Enter module description"
                                />
                                <Form.Control.Feedback type="invalid">
                                    {errors.description}
                                </Form.Control.Feedback>
                            </Form.Group>

                            <FieldArray name="lessons">
                                {({ push, remove }) => (
                                    <div className="mt-4">
                                        <h5>Lessons</h5>
                                        {values.lessons.map((lesson, index) => (
                                            <div key={index} className="mb-3 p-3 border rounded">
                                                <input
                                                    type="hidden"
                                                    name={`lessons[${index}].id`}
                                                    value={lesson.id || index + 1}
                                                />

                                                <Form.Group controlId={`lessons[${index}].title`}>
                                                    <Form.Label>Lesson Title</Form.Label>
                                                    <Form.Control
                                                        type="text"
                                                        name={`lessons[${index}].title`}
                                                        value={lesson.title}
                                                        onChange={handleChange}
                                                        onBlur={handleBlur}
                                                        isInvalid={
                                                            touched.lessons?.[index]?.title &&
                                                            errors.lessons?.[index]?.title
                                                        }
                                                        placeholder="Enter lesson title"
                                                    />
                                                    <Form.Control.Feedback type="invalid">
                                                        {errors.lessons?.[index]?.title}
                                                    </Form.Control.Feedback>
                                                </Form.Group>

                                                <Form.Group controlId={`lessons[${index}].content`} className="mt-3">
                                                    <Form.Label>Lesson Content</Form.Label>
                                                    <Form.Control
                                                        as="textarea"
                                                        rows={3}
                                                        name={`lessons[${index}].content`}
                                                        value={lesson.content}
                                                        onChange={handleChange}
                                                        onBlur={handleBlur}
                                                        isInvalid={
                                                            touched.lessons?.[index]?.content &&
                                                            errors.lessons?.[index]?.content
                                                        }
                                                        placeholder="Enter lesson content"
                                                    />
                                                    <Form.Control.Feedback type="invalid">
                                                        {errors.lessons?.[index]?.content}
                                                    </Form.Control.Feedback>
                                                </Form.Group>

                                                <div className="d-flex justify-content-end mt-3">
                                                    <Button
                                                        variant="danger"
                                                        size="sm"
                                                        onClick={() => remove(index)}
                                                    >
                                                        Remove Lesson
                                                    </Button>
                                                </div>
                                            </div>
                                        ))}
                                        <Button
                                            variant="primary"
                                            className="mt-3"
                                            onClick={() => push({ id: values.lessons.length + 1, title: '', content: '' })}
                                        >
                                            Add Lesson
                                        </Button>
                                    </div>
                                )}
                            </FieldArray>

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
                                    {module ? 'Update Module' : 'Create Module'}
                                </Button>
                            </div>
                        </Form>
                    )}
                </Formik>
            </Modal.Body>
        </Modal>
    );
};

export default CreateEditModuleModal;
