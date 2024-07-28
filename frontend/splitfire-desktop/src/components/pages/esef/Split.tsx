import { Col, Container, Row } from "react-bootstrap";
import { Outlet } from "react-router-dom";

export function Split() {
    return <Container>
        <Row>
            <Col>
                <Outlet />
            </Col>
        </Row>
    </Container>
}