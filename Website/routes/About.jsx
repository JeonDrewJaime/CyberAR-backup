import React from 'react';
import { Container, Row, Col, Card, ListGroup, Button } from 'react-bootstrap';
import Header from '../components/Header';

export const About = () => {
    return (
        <>
            <Header />
            <div className="mt-2">
                <Container>
                    <Row className="mt-4 d-flex align-items-center">
                        <Col lg={6}>
                            <h2 className="mb-4">About CyberQuest</h2>
                            <p>
                                CyberQuest is designed to provide
                                immersive, hands-on experiences to help you understand, respond to, and prevent cyber threats.
                                With interactive simulations and engaging modules for all experience levels, our app offers a
                                unique learning opportunity for anyone looking to enhance their cybersecurity skills.
                            </p>
                        </Col>
                        <Col lg={6}>
                            <img src="https://placehold.co/600x400" alt="CyberQuest" className="img-fluid" />
                        </Col>
                    </Row>

                    <Row className="my-3">
                        <Col>
                            <h3 className="mb-4">Key Features</h3>
                            <Row>
                                <Col md={3} sm={6} className="mb-4">
                                    <Card className="d-flex h-100">
                                        <Card.Body>
                                            <Card.Title>AR-Based Training</Card.Title>
                                            <Card.Text>
                                                Experience realistic cyber threat scenarios using AR to prepare for real-world challenges.
                                            </Card.Text>
                                        </Card.Body>
                                    </Card>
                                </Col>
                                <Col md={3} sm={6} className="mb-4">
                                    <Card className="d-flex h-100">
                                        <Card.Body>
                                            <Card.Title>Threat Simulation</Card.Title>
                                            <Card.Text>
                                                Practice your cybersecurity skills in realistic, risk-free threat simulations.
                                            </Card.Text>
                                        </Card.Body>
                                    </Card>
                                </Col>
                                <Col md={3} sm={6} className="mb-4">
                                    <Card className="d-flex h-100">
                                        <Card.Body>
                                            <Card.Title>Engaging Modules</Card.Title>
                                            <Card.Text>
                                                Choose from beginner to advanced levels that challenge and improve your cybersecurity skills.
                                            </Card.Text>
                                        </Card.Body>
                                    </Card>
                                </Col>
                                <Col md={3} sm={6} className="mb-4">
                                    <Card className="d-flex h-100">
                                        <Card.Body>
                                            <Card.Title>Quizzes & Achievements</Card.Title>
                                            <Card.Text>
                                                Take quizzes, earn points, badges, and achievements in a gamified learning experience.
                                            </Card.Text>
                                        </Card.Body>
                                    </Card>
                                </Col>
                            </Row>
                        </Col>
                    </Row>


                    <Row className="my-3">
                        <Col>
                            <h3 className="mb-4">How to Use</h3>
                            <ul>
                                <li>
                                    <strong>Step 1: Download and Install</strong>
                                    <p>Download the app and install it on your mobile device.</p>
                                </li>
                                <li>
                                    <strong>Step 2: Choose Your Module</strong>
                                    <p>Select from beginner, intermediate, or advanced modules based on your skill level and knowledge.</p>
                                </li>
                                <li>
                                    <strong>Step 3: Start Your Training</strong>
                                    <p>Begin your cybersecurity training by diving into interactive AR-based simulations and threat response scenarios.</p>
                                </li>
                                <li>
                                    <strong>Step 4: Take Quizzes & Earn Achievements</strong>
                                    <p>Test your skills through quizzes, earn experience points, and unlock achievements as you progress.</p>
                                </li>
                                <li>
                                    <strong>Step 5: Review Feedback</strong>
                                    <p>Receive immediate feedback on your performance and review your answers to improve your understanding of cybersecurity.</p>
                                </li>
                            </ul>
                        </Col>
                    </Row>
                </Container>
            </div>

        </>

    );
};
