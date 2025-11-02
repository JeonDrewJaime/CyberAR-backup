import { Col, Container, Row } from 'react-bootstrap';
import game from '../assets/game.png';
import bg1 from '../assets/bg1.jpg';
import Header from '../components/Header';

export const Landing = () => {
    return (
        <>
            <Header />
            <section 
                id="hero" 
                className="d-flex align-items-center text-center text-white"
                style={{
                    background: `linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url(${bg1}) no-repeat center center/cover`,
                    backgroundPosition: 'center',
                    backgroundSize: 'cover',
                    height: '95vh'
                }}
            >
                <Container>
                    <Row>
                        <Col lg={6}>
                            <h2 className='my-4'>CyberQuest: Learn About Cybersecurity with Augmented Reality</h2>
                            <span>Enhance your cybersecurity skills through an interactive and immersive mobile-based training platform. Explore realistic simulations, test your knowledge with quizzes, earn achievements, and track your progress with a dynamic points system. Start your cybersecurity journey today and level up your skills with real-time feedback and engaging learning tools! Available only for Android devices.</span>
                            <div className="mt-4">
                                <a href="https://drive.google.com/drive/folders/1fMBBOqv5aUbAFLOVbnaNCuYQBaKqJKWD?usp=sharing"
                                    target='_blank' rel="noopener noreferrer" className="btn btn-primary text-uppercase px-4">
                                    <i className="bi bi-download me-2"></i>
                                    Download
                                </a>
                            </div>
                        </Col>
                        <Col lg={6}>
                            <div className="col my-4">
                                <img src={game} alt="Logo" width="300" height="200" />
                            </div>
                        </Col>
                    </Row>
                </Container>
            </section>
        </>
    )
}