import axios from "axios"
import { Component, ReactNode } from "react"
import { Row, Col, Spinner, Container } from "react-bootstrap"
import { useParams, Outlet } from "react-router-dom"
import User, { ProfileResponse } from "../../models/user"
import BackView from "./BackView"
import { Tab } from "./Tabs"

export function ProfileNetworksRootView() {
    const { usernameOrId } = useParams()

    if (!usernameOrId) {
        return (
            <p>Something is wrong...</p>
        )
    }
    return (
        <ProfileNetworksView usernameOrId={usernameOrId} />
    )
}

interface ProfileNetworksProps {
    usernameOrId: string
}

interface ProfileNetworksState {
    user: User | null
    tab: Tab | null
    isError: boolean
}

class ProfileNetworksView extends Component<ProfileNetworksProps, ProfileNetworksState> {

    constructor(props: ProfileNetworksProps) {
        super(props)
        this.state = {
            user: null,
            tab: null,
            isError: false
        }
    }

    componentDidMount() {
        axios.get(`/profile/${this.props.usernameOrId}`)
            .then(res => {
                //console.log(res.data)
                const response: ProfileResponse = res.data
                if (response.code === 200) {
                    this.setState({ user: response.user })
                } else {
                    //console.log("Error")
                    this.setState({ isError: true })
                }
            })
            .catch(error => {
                //console.log(error)
                this.setState({ isError: true })
            })
    }

    render(): ReactNode {
        const { user } = this.state

        let content = <Row>
            <Col>
                <Spinner animation='grow' variant='danger'></Spinner>
            </Col>
        </Row>

        if (user) {
            content = <div>
                <BackView user={user} />
                <Outlet />
            </div>
        }

        return <Container>{content}</Container>
    }
}