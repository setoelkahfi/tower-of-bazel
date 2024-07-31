import axios from "axios"
import { Component } from "react"
import { Alert, Button, Col, Container, Form, Row } from "react-bootstrap"
import { Navigate } from "react-router-dom"
import { CurrentUser, CurrentUserType, db } from "../../lib/db"
import User, { ProfileResponse, usernameOrId } from '../../models/user'
import { Mode } from "../player/models/Mode"
import { UserContext } from "../../lib/CurrentUserContext"

interface LoginProps { }

interface LoginState {
    user: User | null
    usernameOrEmail: string
    password: string
    errorMessage: string
    processing: boolean
}

export default class Login extends Component<LoginProps, LoginState> {

    static contextType = UserContext

    constructor(props: LoginProps) {
        super(props)
        this.state = {
            user: null,
            usernameOrEmail: '',
            password: '',
            errorMessage: '',
            processing: false
        }
    }

    componentDidMount() {
        const user = this.context.user
        if (user) {
            this.setState({ user: user })
        }
    }

    login(update: (user: CurrentUser) => void) {
        //console.log(this.state)
        this.setState({ processing: true })
        axios
            .post(`/login`, {
                username: this.state.usernameOrEmail,
                password: this.state.password
            })
            .then(res => {
                const response: ProfileResponse = res.data
                if (response.code === 200) {
                    let currentUser: CurrentUser = {
                        accessToken: res.headers.authorization,
                        type: CurrentUserType.MAIN,
                        user: response.user,
                        mode: Mode.Vocal
                    }
                    db.currentUser.add(currentUser)
                    this.setState({
                        user: response.user
                    })
                    update(currentUser)
                    //this.props.didLogin(response.user)
                } else {
                    //console.log(res)
                    this.setState({
                        processing: false,
                        errorMessage: response.message
                    })
                }
            })
            .catch(error => {
                //console.log(error)
                this.setState({
                    processing: false,
                    errorMessage: 'Unkown error.'
                })
            })
    }

    _buttonTitle(): string {
        if (this.state.processing) {
            return 'Logging in...'
        }
        return 'Submit'
    }

    render() {
        const { user, errorMessage } = this.state

        if (user) {
            return <Navigate to={`/${usernameOrId(user)}`} />
        }

        let validationText: any = ''
        if (errorMessage.length > 0) {
            validationText = <Alert variant="danger" onClose={() => this.setState({ errorMessage: '' })} dismissible>
                <p>{errorMessage}</p>
                <p><a href={`${process.env.REACT_APP_MUSIK88_BASE_URL}/users/password/new`} target="__blank">Forget password?</a></p>
            </Alert >
        }

        return (
            <UserContext.Consumer>
                {({ user, updateUser: update }) => (
                    <Row className="justify-content-md-center">
                        <Col>
                            <Container>
                                <Form>
                                    {validationText}
                                    <Form.Group className="mb-3" controlId="formBasicEmail">
                                        <Form.Label>Email address</Form.Label>
                                        <Form.Control type="email" placeholder="Enter email" value={this.state.usernameOrEmail} onChange={(e) => this.setState({ usernameOrEmail: e.currentTarget.value })} />
                                    </Form.Group>
                                    <Form.Group className="mb-3" controlId="formBasicPassword">
                                        <Form.Label>Password</Form.Label>
                                        <Form.Control type="password" placeholder="Password" value={this.state.password} onChange={(e) => this.setState({ password: e.currentTarget.value })} />
                                    </Form.Group>
                                    <Button variant="primary" onClick={() => this.login(update)} disabled={this.state.processing}>
                                        {this._buttonTitle()}
                                    </Button>
                                    <p>or</p>
                                    <Form.Group className="mb-3">
                                        <a href={`${process.env.REACT_APP_MUSIK88_BASE_URL}/signup`} target={`__blank`}>
                                            <Button variant="success">
                                                Register
                                            </Button>
                                        </a>
                                        <p>Account managed by Musik88.</p>
                                    </Form.Group>
                                </Form>
                            </Container>
                        </Col>
                    </Row>
                )}
            </UserContext.Consumer>
        )
    }
}