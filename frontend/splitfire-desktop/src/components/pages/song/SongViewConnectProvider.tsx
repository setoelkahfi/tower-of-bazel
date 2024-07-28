import { useEffect, useState } from "react";
import { Form, Row, Col, Button, Alert } from "react-bootstrap";
import { FormattedMessage } from "react-intl";
import { CurrentUserType, db } from "../../../lib/db";
import { Navigate } from "react-router-dom";
import { Payload } from "./SongView";
import axios from "axios";

interface Props {
    referenceId: string
    name: string
    onAddedProvider: (payload: Payload) => void
}

enum State {
    IDLE,
    LOADING,
    LOADED,
    ERROR
}

export default function SongViewConnectProvider(props: Props) {

    const [validUrl, setValidUrl] = useState(false)
    const [url, setUrl] = useState("")
    const [errorMessage, setErrorMessage] = useState("")
    const [accessToken, setAccessToken] = useState<string | null>(null)
    const [redirectToLogin, setRedirectToLogin] = useState(false)
    const [, setState] = useState(State.IDLE)

    useEffect(() => {
        db
            .currentUser
            .where({ type: CurrentUserType.MAIN })
            .first()
            .then(res => {
                console.log(res)
                if (res?.accessToken) {
                    setAccessToken(res?.accessToken)
                }
            }).catch(error => {
                console.log(error)
            })
    }, [])

    const validateYoutubeUrl = (url: string) => {
        if (url.length === 0) {
            setErrorMessage('URL is required')
            setValidUrl(false)
        }
        if (url.startsWith("https://www.youtube.com/watch?v=")) {
            setValidUrl(true)
            setUrl(url)
            setErrorMessage('')
        } else {
            setErrorMessage('Invalid YouTube URL')
            setValidUrl(false)
        }
    }

    const onAddUrl = () => {
        if (!accessToken) {
            setRedirectToLogin(true)
            return
        }
        if (validUrl) {
            const videoId = url.replace("https://www.youtube.com/watch?v=", "")
            console.log(videoId)

            addSongProvider({
                reference_id: props.referenceId,
                provider_id: videoId,
                name: props.name,
                provider: 'youtube'
            }, accessToken)
        }
    }

    const addSongProvider = (payload: Payload, accessToken: string) => {
        console.log(payload)
        setState(State.LOADING)
        axios
            .post(`/song-bridge`, payload, {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': accessToken,
                }
            })
            .then(res => {
                console.log("Get results", res);
                setState(State.LOADED)
                setUrl('')
                props.onAddedProvider(payload)
            })
            .catch(error => {
                //console.log(error)
                setState(State.ERROR)
                setErrorMessage('Something went wrong')
            })
    }

    if (redirectToLogin) {
        return <Navigate to={'/login'} />
    }

    let validationText: any = ''
    if (errorMessage.length > 0) {
        validationText = <Alert variant="danger" onClose={() => setErrorMessage('')} dismissible><p>{errorMessage}</p></Alert>
    }

    return (
        <Row>
            <Col xs={3}>
                <h4>
                    <FormattedMessage id="song.connect-provider"
                        defaultMessage="Add more"
                        description="Connect provider" />
                </h4>
            </Col>
            <Col xs={9}>
                <Form onSubmit={(e) => e.preventDefault()}>
                    <Row>
                        <Col xs={8}>
                            <Form.Control
                                placeholder="Put YouTube URL here..."
                                className="mb-3"
                                onChange={(e) => validateYoutubeUrl(e.target.value)}
                            />
                            {validationText}
                        </Col>
                        <Col xs={{ span: 3, offset: 1 }}>
                            <Button variant="primary" onClick={() => onAddUrl()} disabled={!validUrl}>Add</Button>
                        </Col >
                    </Row>
                </Form >
            </Col>
        </Row>
    )
}