import axios from "axios"
import { Component, ReactNode } from "react"
import { Col, Row, Spinner } from "react-bootstrap"
import { useParams } from "react-router-dom"
import User, { FollowersResponse } from "../../models/user"
import ProfileFollowingView from "./ProfileListView"
import TabMenu, { Tab } from "./Tabs"

export function ProfileFollowersRootView() {
    const { usernameOrId } = useParams()

    if (!usernameOrId) {
        return (
            <p>Something is wrong...</p>
        )
    }

    return (
        <ProfileFollowers usernameOrId={usernameOrId} />
    )
}

interface ProfileFollowersProps {
    usernameOrId: string
}

interface ProfileFollowersState {
    user: User | null
    followers: User[] | null
}

class ProfileFollowers extends Component<ProfileFollowersProps, ProfileFollowersState> {

    constructor(props: ProfileFollowersProps) {
        super(props)
        this.state = {
            user: null,
            followers: null
        }
    }

    componentDidMount() {
        axios.get(`/profile/${this.props.usernameOrId}/followers`)
        .then(res => {
            //console.log(res.data)

            const response: FollowersResponse = res.data
            if (response.code === 200) {
                this.setState({ user: response.user, followers: response.followers })
            } else {
                //console.log("Error")
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

        if (this.state.user && this.state.followers) {
            content = <ProfileFollowingView following={this.state.followers} />
        }

        return <div>
            <TabMenu active={Tab.Followers} usernameOrId={this.props.usernameOrId} />
            {content}
        </div>
    }
}