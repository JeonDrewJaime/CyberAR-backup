import React from 'react'
import { Card, Container, Row, Col } from 'react-bootstrap'

const DashboardCards = ({ dashboardCardsData }) => {

    return (
        <div>
            <Container className='my-4'>
                <Row>
                    {
                        dashboardCardsData.map((card, index) => (
                            <Col key={index}>
                                <Card className="text-center" key={card.title}>
                                    <Card.Body>
                                        <Card.Title>{card.title}</Card.Title>
                                        <Card.Text className="display-4">
                                            {card.value}
                                        </Card.Text>
                                    </Card.Body>
                                </Card>
                            </Col>
                        ))
                    }
                </Row>
            </Container>
        </div>
    )
}

export default DashboardCards
