import { Col, Container, Spinner } from "react-bootstrap";

export function LoadingView() {

    return <Container>
        <Col className="align-self-center" xs={12}>
            <Spinner animation="grow" role="status" variant="danger">
                <span className="visually-hidden">Loading...</span>
            </Spinner>
        </Col>
    </Container>
}