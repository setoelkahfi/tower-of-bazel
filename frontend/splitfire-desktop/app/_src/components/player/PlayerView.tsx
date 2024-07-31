import { useContext } from "react";
import { Navigate, Outlet, useParams } from "react-router-dom";
import { UserContext } from "../../lib/CurrentUserContext";
import { Col, Container, Row } from "react-bootstrap";
import ErrorView from "../templates/Error";

export function PlayerView() {

    const { providerId } = useParams()
    const { user } = useContext(UserContext)

    if (!user) {
        return <Navigate to={'/login'} />
    }

    if (user && providerId) {
        return <Container>
            <Row>
                <Col xs={12} className="mb-3 mt-3">
                    <h1>Let's play!</h1>
                </Col>
            </Row>
            <Outlet context={{ user }} />
        </Container>
    }

    return <ErrorView errorMessage="Something went wrong ..." />
}