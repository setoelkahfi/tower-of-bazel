import { Container, Row, Col } from "react-bootstrap";
import { MdBugReport } from "react-icons/md";

export default function ErrorView(props: { errorMessage: string }) {
    return (
        <Container>
                <Row>
                    <Col>
                        <MdBugReport size={50} color="red" />
                        <p>{props.errorMessage}</p>
                    </Col>
                </Row>
            </Container>
    )
}