import { useState } from "react"
import User, { usernameOrId } from "../../models/user"
import { Mode } from "../player/models/Mode"
import { Button, Col, Form, Row, Spinner, Image } from "react-bootstrap"
import { Link } from "react-router-dom"
import { useLogger } from "../../../../lib/logger"


interface ProfileViewProps {
    user: User
    isCurrentUser: boolean
    isUpdatingMode: boolean
    mode: Mode
    onChangeMode: (mode: Mode) => Promise<Mode>
}

export default function ProfileView(props: ProfileViewProps) {

    const log = useLogger('ProfileView')
    const [updatingMode, setUpdatingMode] = useState(props.isUpdatingMode)
    const [currentMode, setCurrentMode] = useState(props.mode)

    log.debug(props.mode)
    log.debug(currentMode)

    const modeChangeHander = (stringMode: string) => {
        setUpdatingMode(true)
        props
            .onChangeMode(stringMode as Mode)
            .then(mode => {
                setUpdatingMode(false)
                setCurrentMode(mode)
            })
    }

    let logoutButton

    if (props.isCurrentUser) {
        logoutButton = <Col xs={12} className="mt-3 font-weight-bold">
            <Link to={'/logout'} ><Button variant="danger">Logout</Button></Link>
        </Col>
    }
    let modeView
    if (!updatingMode && props.isCurrentUser) {
        let options = []
        for (const value in Mode) {
            if (typeof value !== "string") {
                continue;
            }
            if (value === 'Keyboard') {
                continue;
            }
            options.push(<option value={value} key={value}> {value}</option >)
        }
        modeView = <Col xs={{ span: 4, offset: 4 }} className="mt-3">
            <Form.Select onChange={(e) => modeChangeHander(e.currentTarget.value)} value={currentMode}>
                {options}
            </Form.Select>
        </Col>
    }
    if (updatingMode) {
        modeView = <Col xs={{ span: 4, offset: 4 }} className="mt-3">
            <Spinner animation='grow' variant='danger'></Spinner>
        </Col>
    }

    return (
        <div className="mt-3">
            <Row>
                <Col xs={12}>
                    <Image roundedCircle thumbnail src={props.user.gravatar_url} />
                </Col>
                <Col xs={12} className="mt-3 font-weight-bold">
                    {props.user.name}
                </Col>
                <Col xs={12} className="mt-3 font-weight-light">
                    {usernameOrId(props.user)}
                </Col>
                {modeView}
                <Col xs={12} className="mt-3 blockquote-footer">
                    {props.user.about}
                </Col>
                {logoutButton}
            </Row>
            <Row className="mt-3">
                <Col xs={6}>
                    <Link to={`/${usernameOrId(props.user)}/followers`} className="text-white" aria-current="page">
                        {props.user.followers_count} Followers
                    </Link>
                </Col>
                <Col xs={6}>
                    <Link to={`/${usernameOrId(props.user)}/following`} className="text-white" aria-current="page">
                        {props.user.following_count} Following
                    </Link>
                </Col>
            </Row>
        </div>
    )
}