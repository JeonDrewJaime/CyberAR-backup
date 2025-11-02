import { useContext, useState, useEffect } from 'react';
import { Card, Form, Button, Container, Col } from 'react-bootstrap';
import { Formik } from 'formik';
import * as Yup from 'yup';
import { useNavigate } from 'react-router-dom';
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from '../firebase';
import { AuthContext } from '../auth/AuthContext.jsx';
import Header from '../components/Header.jsx';
import { getUsers } from '../services/usersService';

export const Login = () => {
    const [firebaseError, setFirebaseError] = useState('');
    const navigate = useNavigate();
    const [users, setUsers] = useState([]);

    const { dispatch } = useContext(AuthContext);

    const validationSchema = Yup.object().shape({
        email: Yup.string().email('Invalid email address').required('Email is required'),
        password: Yup.string().min(6, 'Password must be at least 6 characters').required('Password is required'),
    });

    const handleSignIn = (values, { setSubmitting, setErrors }) => {
        setFirebaseError('');
        try {
            const existingUser = users.find(user => user.email === values.email);

            if (existingUser && existingUser.isTeacher) {
                dispatch({ type: 'LOGIN', payload: existingUser })
                navigate('/teacher');
                setSubmitting(false);
                return;
            } else {
                signInWithEmailAndPassword(auth, values.email, values.password)
                    .then((userCredential) => {
                        const user = userCredential.user;
                        dispatch({ type: 'LOGIN', payload: user })
                        navigate('/admin');
                    }).catch((error) => {
                        setFirebaseError("Invalid email or password");
                    });
            }
        } catch (e) {
            console.error(e);
            setErrors({ email: 'Invalid email or password' });
        }
        setSubmitting(false);
    };

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            const response = await getUsers();
            setUsers(response);
        } catch (error) {
            console.error('Error fetching users:', error);
        }
    }

    return (
        <div>
            <Header />
            <div id="hero" className="d-flex align-items-center text-white">
                <Container>
                    <Col lg={4} className="mx-auto">
                        <Card className="px-2 py-4">
                            <Card.Title className="text-center mb-4 fs-2">Login as Admin</Card.Title>
                            <Card.Body>
                                <Formik
                                    initialValues={{ email: '', password: '' }}
                                    validationSchema={validationSchema}
                                    onSubmit={handleSignIn}
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
                                            <Form.Group controlId="formEmail" className="mb-3">
                                                <Form.Label>Email</Form.Label>
                                                <Form.Control
                                                    type="email"
                                                    name="email"
                                                    placeholder="Enter email"
                                                    value={values.email}
                                                    onChange={handleChange}
                                                    isInvalid={touched.email && !!errors.email}
                                                />
                                                <Form.Control.Feedback type="invalid">
                                                    {errors.email}
                                                </Form.Control.Feedback>
                                            </Form.Group>
                                            <Form.Group controlId="formPassword" className="mb-3">
                                                <Form.Label>Password</Form.Label>
                                                <Form.Control
                                                    type="password"
                                                    name="password"
                                                    placeholder="Enter password"
                                                    value={values.password}
                                                    onChange={handleChange}
                                                    isInvalid={touched.password && !!errors.password}
                                                />
                                                <Form.Control.Feedback type="invalid">
                                                    {errors.password}
                                                </Form.Control.Feedback>
                                            </Form.Group>
                                            {firebaseError && (
                                                <div className="text-danger mb-3">
                                                    {firebaseError}
                                                </div>
                                            )}
                                            <Button
                                                variant="primary"
                                                type="submit"
                                                className="w-100"
                                                disabled={isSubmitting}
                                            >
                                                {isSubmitting ? 'Logging in...' : 'Login'}
                                            </Button>
                                        </Form>
                                    )}
                                </Formik>
                            </Card.Body>
                        </Card>

                    </Col>
                </Container>
            </div>
        </div>
    );
};