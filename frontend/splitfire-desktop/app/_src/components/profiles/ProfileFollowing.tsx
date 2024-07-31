import axios from "axios"
import { Component, ReactNode } from "react"
import { Col, Row, Spinner } from "react-bootstrap"
import { useParams } from "react-router-dom"
import User, { FollowingResponse } from '../../models/user'
import ProfileFollowingView from "./ProfileListView"
import TabMenu, { Tab } from "./Tabs"

export function ProfileFollowingRootView() {
    const { usernameOrId } = useParams()

    if (!usernameOrId) {
        return (
            <p>Something is wrong...</p>
        )
    }

    return (
        <ProfileFollowing usernameOrId={usernameOrId} />
    )
}

interface ProfileFollowingProps {
    usernameOrId: string
}

interface ProfileFollowingState {
    user: User | null
    following: User[] | null
}

class ProfileFollowing extends Component<ProfileFollowingProps, ProfileFollowingState> {

    constructor(props: ProfileFollowingProps) {
        super(props)
        this.state = {
            user: null,
            following: null
        }
    }

    componentDidMount() {
        axios.get(`/profile/${this.props.usernameOrId}/following`)
            .then(res => {
                //console.log(res.data)

                const response: FollowingResponse = res.data
                if (response.code === 200) {
                    this.setState({ user: response.user, following: response.following })
                } else {
                    //console.log('Error')
                }
            })
            .catch(error => {
                //console.log(error)
            })
    }

    render(): ReactNode {
        let content = <Row>
            <Col>
                <Spinner animation='grow' variant='danger'></Spinner>
            </Col>
        </Row>

        if (this.state.user && this.state.following) {
            content = <ProfileFollowingView following={this.state.following} />
        }

        return <div>
            <TabMenu active={Tab.Following} usernameOrId={this.props.usernameOrId} />
            {content}
        </div>
    }
}

export default ProfileFollowing