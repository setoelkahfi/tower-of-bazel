import { Row, Col, Container, Image } from "react-bootstrap"
import { Link } from "react-router-dom"
import User, { usernameOrId } from "../../models/user"

interface ProfileListViewProps {
    key: number
    user: User
}

interface ProfileFollowingViewProps {
    following: User[]
}

export default function ProfileFollowingView(props: ProfileFollowingViewProps) {
    let content = <p>Nothing here :(</p>
    if (props.following.length > 0) {
        content = <div>
            {props.following.map( user => 
                (<ProfileListView user={user} key={user.id} />)
             )}
        </div>
    }
    return (
        content
    )
}

function ProfileListView(props: ProfileListViewProps) {
    return (
        <Row className="m-3">
            <Col xs={2}>
                <Image roundedCircle thumbnail src={props.user.gravatar_url} sizes={'24x24'}/>
            </Col>
            <Col xs={10} className="text-start">
                <Container>
                    <Row>
                        <Col xs={8} className="mt-3 font-weight-bold">
                            <div>
                            <Link to={`/${usernameOrId(props.user)}`}>
                                {props.user.name}
                            </Link>
                            </div>
                            <div>
                            {`${usernameOrId(props.user)}`}
                            </div>
                        </Col>
                        <Col xs={4} className="mt-3 font-weight-light float-end">
                            <span className="badge rounded-pill bg-primary">{`${props.user.followers_count}`} Followers</span>
                            <span className="badge rounded-pill bg-primary">{`${props.user.following_count}`} Following</span>
                        </Col>
                    </Row>
                </Container>
                <Container className="blockquote-footer">
                    <Row>
                        <Col>
                            {props.user.about}
                        </Col>
                    </Row>
                </Container>
            </Col>
        </Row>
    )
}