import axios from "axios"
import { Component } from "react"
import { Col, Container, Row, Spinner } from "react-bootstrap"
import { useParams } from "react-router-dom"
import { db, CurrentUserType } from "../../lib/db"
import User, { ProfileResponse } from '../../models/user'
import { Mode } from "../player/models/Mode"
import ProfileView from "./ProfileView"
import { UserContext } from "../../lib/CurrentUserContext"
import { Logger } from "tslog"
import { MdBugReport } from "react-icons/md"
import ErrorView from "../templates/Error"

export function ProfileRootView() {
    const { usernameOrId } = useParams()

    if (!usernameOrId) {
        return (
            <p>Something is wrong...</p>
        )
    }

    return (
        <Profile usernameOrId={usernameOrId} />
    )
}

interface ProfileProps {
    usernameOrId: string
}

interface ProfileState {
    user: User | null
    isCurrentUser: boolean
    errorMessage: string
    mode: Mode
    isUpdatingMode: boolean
}

class Profile extends Component<ProfileProps, ProfileState> {

    static contextType = UserContext
    log = new Logger({ name: 'Profile', type: 'pretty' })

    constructor(props: ProfileProps) {
        super(props)
        this.state = {
            user: null,
            isCurrentUser: false,
            errorMessage: '',
            mode: Mode.Vocal,
            isUpdatingMode: false
        }
    }

    componentDidUpdate(prevProps: ProfileProps) {
        if (this.props.usernameOrId !== prevProps.usernameOrId) {
            this._fetchUserDetail()
        }
    }

    onChangeMode(mode: Mode): Promise<Mode> {
        this.log.debug(mode)
        this.setState({ isUpdatingMode: true })
        return new Promise<Mode>((resolve, reject) => {
            db
                .currentUser
                .where({ type: CurrentUserType.MAIN })
                .modify({ mode })
                .finally(() => {
                    this.setState({ isUpdatingMode: false })
                    resolve(mode)
                })
        })
    }

    componentDidMount() {
        this._fetchUserDetail()
    }

    _fetchUserDetail() {
        axios.get(`/profile/${this.props.usernameOrId}`)
            .then(res => {
                this.log.debug(res.data)
                const response: ProfileResponse = res.data
                if (response.code === 200) {
                    this.setState({ user: response.user })
                    this._updateCurrentUserState()
                } else {
                    this.setState({ errorMessage: response.message })
                }
            })
            .catch(error => {
                this.log.error(error)
                this.setState({ errorMessage: 'Something went wrong...' })
            })
    }

    _updateCurrentUserState() {
        const user = this.context.user
        const isCurrentUser = user.user.id === this.state.user?.id
        this.setState({ isCurrentUser, mode: user?.mode })
    }

    render() {

        const { user, isCurrentUser, errorMessage, mode, isUpdatingMode } = this.state
        this.log.debug(mode)
        let content = <Row>
            <Col>
                <Spinner animation='grow' variant='danger'></Spinner>
            </Col>
        </Row>

        if (user) {
            content = <ProfileView
                user={user}
                isCurrentUser={isCurrentUser}
                mode={mode}
                onChangeMode={this.onChangeMode.bind(this)}
                isUpdatingMode={isUpdatingMode}
            />
        }

        if (errorMessage.length > 0) {
            return <ErrorView errorMessage={errorMessage} />
        }

        return (
            <Container>
                {content}
            </Container>
        )
    }
}

export default Profile