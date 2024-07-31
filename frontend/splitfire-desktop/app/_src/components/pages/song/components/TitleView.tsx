import { Col, Row } from "react-bootstrap";

export function TitleView(props: { name: string }) {
    return (
        <Row className="mb-5">
            <Col>
                <h1 className="title text-center">{`Upvotes "${props.name}" so we can jam together!`}</h1>
            </Col>
        </Row>
    )
}