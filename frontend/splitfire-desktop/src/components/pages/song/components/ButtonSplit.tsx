import { useContext, useState } from "react"
import { AudioFile, Status } from "../../../player/models/AudioFile"
import { UserContext } from "../../../../lib/CurrentUserContext"
import requestSplitService, { SplitResponse } from "../../../../lib/requestSplitService"
import { Col, Spinner } from "react-bootstrap"
import { GiSandsOfTime, GiSpaceShuttle } from "react-icons/gi"
import { MdNotificationImportant } from "react-icons/md"
import { Navigate } from "react-router-dom"
import { HTTPStatusCode } from "../../esef/SplitFireView"
import { BsPlayCircle } from "react-icons/bs"

enum State {
    LOADING,
    LOADED,
    ERROR,
}

export function ButtonSplit(props: { providerId: string, audioFile: AudioFile | null, aggregateVotes: number }) {

    const [state, setState] = useState(State.LOADED)
    const { user } = useContext(UserContext)
    const [goToLogin, setGoToLogin] = useState(false)
    const [audioFile, setAudioFile] = useState<AudioFile | null>(null)

    useState(() => {
        setAudioFile(props.audioFile)
    })

    const splitRequest = () => {
        if (!user || !user.accessToken) {
            setGoToLogin(true)
            return
        }

        setState(State.LOADING)
        requestSplitService(props.providerId, user.accessToken)
            .then(res => {
                console.log(res)
                const response: SplitResponse = res.data
                if (response.code === HTTPStatusCode.OK) {
                    setAudioFile(response.audio_file)
                    setState(State.LOADED)
                } else {
                    setState(State.ERROR)
                }
            })
            .catch(error => {
                console.log(error)
                setState(State.ERROR)
            })
    }

    // Default to production value.
    const splitTreshold = process.env.REACT_APP_SPLIT_THRESHOLD ? parseInt(process.env.REACT_APP_SPLIT_THRESHOLD) : 5

    const isDoneSplitting = audioFile && audioFile.status === Status.DONE
    const isCurrentlySplitting = audioFile && (audioFile.status === Status.SPLITTING || audioFile.status === Status.DOWNLOADING)
    const isReadyToSplit = props.aggregateVotes > splitTreshold

    if (goToLogin) {
        return <Navigate to={'/login'} />
    }

    if (state === State.LOADING) {
        return <Col className="align-self-center" xs={12}>
            <Spinner animation="border" role="status">
                <span className="visually-hidden">Loading...</span>
            </Spinner>
        </Col>
    }
    // Check if we have processed the split request.
    if (isDoneSplitting) {
        return <Col className="align-self-center mb-3 mt-3" xs={12}>
            <h1>Let's Play!</h1>
        </Col>
    } else if (isCurrentlySplitting) {
        return <Col className="align-self-center mb-3 mt-3" xs={12}>
            <GiSandsOfTime
                size={40}
                className="mb-3"
                color="green"
                title="Split request in progress..." />
        </Col>
    } else if (isReadyToSplit) {
        return <Col className="align-self-center mb-3 mt-3" xs={12}>
            <GiSpaceShuttle
                size={40}
                className="mb-3"
                onClick={splitRequest}
                style={{ cursor: "pointer" }}
                color="green"
                title="Split request..." />
        </Col>
    }

    return <Col className="align-self-center mb-3 mt-3" xs={12}>
        <MdNotificationImportant size={40} className="mb-3" color="green" title="Not enough votes to split..." />
    </Col>
}