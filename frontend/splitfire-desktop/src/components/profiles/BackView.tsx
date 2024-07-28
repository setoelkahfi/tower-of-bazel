import { Row, Col } from "react-bootstrap"
import { BsArrowLeft } from "react-icons/bs"
import { Link } from "react-router-dom"
import User, { usernameOrId } from "../../models/user"

interface BackViewProps {
    user: User
}

export default function BackView(props: BackViewProps) {
    return (
        <Row className="mb-2">
            <Col xs={1} className="text-start">
                <Link to={`/${usernameOrId(props.user)}`}>
                    <BsArrowLeft></BsArrowLeft>
                </Link>
            </Col>
            <Col xs={11} className="text-start">
                <div className="">{`${props.user.name}`}</div>
                <div className="">{`${usernameOrId(props.user)}`}</div>
            </Col>
        </Row>
    )
}