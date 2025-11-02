import { useState } from 'react';
import { Modal, Button, Form, InputGroup } from 'react-bootstrap';
import { Formik, FieldArray } from 'formik';
import * as Yup from 'yup';
import { createAssessment, editAssessment } from '../../services/assessmentsService';

const validationSchema = Yup.object().shape({
    module: Yup.string().required('Module is required'),
    questions: Yup.array().of(
        Yup.object().shape({
            statement: Yup.string().required('Question statement is required'),
            description: Yup.string().required('Description is required'),
            choices: Yup.array().of(
                Yup.object().shape({
                    statement: Yup.string().required('Choice statement is required'),
                    isCorrect: Yup.boolean().required('Correct choice status is required'),
                })
            ).min(1, 'At least one choice is required'),
        })
    ).min(1, 'At least one question is required'),
});

const CreateEditAssessmentModal = ({ show, handleClose, assessment, onUpdate, modules }) => {
    const initialValues = {
        module: assessment?.module || '',
        questions: assessment?.questions || [{ statement: '', description: '', id: 1, choices: [{ id: 1, statement: '', isCorrect: false }] }],
    };

    const handleSubmit = async (values, { setSubmitting }) => {
        try {
            if (assessment && assessment.id !== null) {
                await editAssessment(assessment.id, values);
            } else {
                await createAssessment(values);
            }

            onUpdate(values);
            handleClose();
        } catch (error) {
            console.error('Failed to save assessment:', error);
        } finally {
            setSubmitting(false);
        }
    };

    return (
        <Modal show={show} onHide={handleClose} size="lg">
            <Modal.Header closeButton>
                <Modal.Title>{assessment ? 'Edit Assessment' : 'Create Assessment'}</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Formik
                    initialValues={initialValues}
                    validationSchema={validationSchema}
                    onSubmit={handleSubmit}
                >
                    {({ values, errors, touched, handleChange, handleBlur, handleSubmit, isSubmitting }) => (
                        <Form noValidate onSubmit={handleSubmit}>
                            <Form.Group controlId="formModule">
                                <Form.Label>Module</Form.Label>
                                <Form.Control
                                    as="select"
                                    name="module"
                                    value={values.module}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    isInvalid={touched.module && errors.module}
                                >
                                    <option value="">Select Module</option>
                                    {modules.map((module) => (
                                        <option key={module.id} value={module.title}>
                                            Module {module.moduleNumber}: {module.title}
                                        </option>
                                    ))}
                                </Form.Control>
                                <Form.Control.Feedback type="invalid">
                                    {errors.module}
                                </Form.Control.Feedback>
                            </Form.Group>
                            <Form.Group controlId="courseSummary" className="mt-2">
                                <Form.Label>Course Summary</Form.Label>
                                <Form.Control
                                    as="textarea"
                                    name="courseSummary"
                                    value={values.courseSummary}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    placeholder="Enter course summary"
                                />
                            </Form.Group>
                            <Form.Group controlId="learningOutcome" className="mt-2">
                                <Form.Label>Learning Outcome</Form.Label>
                                <Form.Control
                                    as="textarea"
                                    name="learningOutcome"
                                    value={values.learningOutcome}
                                    onChange={handleChange}
                                    onBlur={handleBlur}
                                    placeholder="Enter learning outcome"
                                />
                            </Form.Group>

                            {/* FieldArray for Questions */}
                            <FieldArray name="questions">
                                {({ push, remove }) => (
                                    <div className="mt-4">
                                        <h5>Questions</h5>
                                        {values.questions.map((question, index) => (
                                            <div key={index} className="mb-3 p-3 border rounded">
                                                <input
                                                    type="hidden"
                                                    name={`questions[${index}].id`}
                                                    value={question.id || index + 1}
                                                />

                                                <h6 className='fw-bold'>Question {question.id || index + 1}</h6>

                                                <Form.Group controlId={`questions[${index}].statement`}>
                                                    <Form.Label>Question Statement</Form.Label>
                                                    <Form.Control
                                                        type="text"
                                                        name={`questions[${index}].statement`}
                                                        value={question.statement}
                                                        onChange={handleChange}
                                                        onBlur={handleBlur}
                                                        isInvalid={touched.questions?.[index]?.statement && errors.questions?.[index]?.statement}
                                                        placeholder="Enter question statement"
                                                    />
                                                    <Form.Control.Feedback type="invalid">
                                                        {errors.questions?.[index]?.statement}
                                                    </Form.Control.Feedback>
                                                </Form.Group>

                                                {/* FieldArray for Choices inside each Question */}
                                                <FieldArray name={`questions[${index}].choices`}>
                                                    {({ push: pushChoice, remove: removeChoice }) => (
                                                        <div className="mt-3">
                                                            <h6>Choices</h6>
                                                            <small className='text-danger'>*Please check the correct answer</small>
                                                            {question.choices.map((choice, choiceIndex) => (
                                                                <div key={choiceIndex} className="mb-2">
                                                                    <input
                                                                        type="hidden"
                                                                        name={`questions[${index}].choices[${choiceIndex}].id`}
                                                                        value={choice.id || choiceIndex + 1}
                                                                    />

                                                                    <InputGroup>
                                                                        <InputGroup.Text>
                                                                            <Form.Check
                                                                                type="checkbox"
                                                                                name={`questions[${index}].choices[${choiceIndex}].isCorrect`}
                                                                                checked={choice.isCorrect}
                                                                                onChange={() =>
                                                                                    handleChange({
                                                                                        target: {
                                                                                            name: `questions[${index}].choices[${choiceIndex}].isCorrect`,
                                                                                            value: !choice.isCorrect,
                                                                                        },
                                                                                    })
                                                                                }
                                                                            />

                                                                        </InputGroup.Text>
                                                                        <Form.Control
                                                                            type="text"
                                                                            name={`questions[${index}].choices[${choiceIndex}].statement`}
                                                                            value={choice.statement}
                                                                            onChange={handleChange}
                                                                            onBlur={handleBlur}
                                                                            placeholder="Enter choice statement"
                                                                            isInvalid={
                                                                                touched.questions?.[index]?.choices?.[choiceIndex]?.statement &&
                                                                                errors.questions?.[index]?.choices?.[choiceIndex]?.statement
                                                                            }
                                                                        />
                                                                    </InputGroup>
                                                                    <Form.Control.Feedback type="invalid">
                                                                        {errors.questions?.[index]?.choices?.[choiceIndex]?.statement}
                                                                    </Form.Control.Feedback>
                                                                </div>
                                                            ))}
                                                            <Button
                                                                variant="primary"
                                                                size="sm"
                                                                onClick={() => pushChoice({ id: values.questions[index].choices.length + 1, statement: '', isCorrect: false })}
                                                            >
                                                                Add Choice
                                                            </Button>
                                                        </div>
                                                    )}
                                                </FieldArray>

                                                <Form.Group controlId={`questions[${index}].description`} className='mt-2'>
                                                    <Form.Label>Answer Description</Form.Label>
                                                    <Form.Control
                                                        type="text"
                                                        name={`questions[${index}].description`}
                                                        value={question.description}
                                                        onChange={handleChange}
                                                        onBlur={handleBlur}
                                                        isInvalid={touched.questions?.[index]?.description && errors.questions?.[index]?.statement}
                                                        placeholder="Enter answer description"
                                                    />
                                                    <Form.Control.Feedback type="invalid">
                                                        {errors.questions?.[index]?.description}
                                                    </Form.Control.Feedback>
                                                </Form.Group>

                                                <div className="d-flex justify-content-end mt-3">
                                                    <Button
                                                        variant="danger"
                                                        size="sm"
                                                        onClick={() => remove(index)}
                                                    >
                                                        Remove Question
                                                    </Button>
                                                </div>
                                            </div>
                                        ))}
                                        <Button
                                            variant="primary"
                                            className="mt-3"
                                            onClick={() => push({ id: values.questions.length + 1, statement: '', choices: [{ id: 1, statement: '', isCorrect: false }] })}
                                        >
                                            Add Question
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
                                    {assessment ? 'Update Assessment' : 'Create Assessment'}
                                </Button>
                            </div>
                        </Form>
                    )}
                </Formik>
            </Modal.Body>
        </Modal>
    );
};

export default CreateEditAssessmentModal;
