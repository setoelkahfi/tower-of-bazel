import { Row, Col, Container, Image } from "react-bootstrap";
import { GiPlayButton, GiTimeBomb } from "react-icons/gi";
import { MdCallSplit } from "react-icons/md";
import { Payload } from "./SongView";
import { useEffect, useState } from "react";
import { db, CurrentUserType } from "../../../lib/db";
import { Link, Navigate } from "react-router-dom";
import axios from "axios";
import { SongProvider } from "../../../models/SongResponse";
import { Status } from "../../player/models/AudioFile";

interface SongViewItemsProps {
    referenceId: string
    items: SongProvider[]
}

enum State {
    IDLE,
    LOADING,
    LOADED,
    ERROR
}

export default function SongViewItems(props: SongViewItemsProps) {
    return (
        <>
            <Row className="mb-3">
                <Col>
                    <Container className="mb-5">
                        <Row className="mb-3">
                            <Col>
                                <h3>Play this song!</h3>
                            </Col>
                        </Row>
                        {props.items.map((video, index) =>
                            <SongViewItem key={index} provider={video} referenceId={props.referenceId} />
                        )}
                    </Container>
                </Col>
            </Row>
        </>
    )
}

interface SongViewItemProps {
    referenceId: string
    provider: SongProvider
}

function SongViewItem(props: SongViewItemProps) {

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

    const [state, setstate] = useState(State.IDLE)
    const [accessToken, setAccessToken] = useState<string | null>(null)
    const [redirectToLogin, setRedirectToLogin] = useState(false)

    const onRequestSplit = (videoId: string) => {
        if (!accessToken) {
            setRedirectToLogin(true)
            return
        }

        addSongProvider({
            reference_id: props.referenceId,
            provider_id: videoId,
            name: props.provider.name,
            provider: 'youtube'
        }, accessToken)
    }

    const addSongProvider = (payload: Payload, accessToken: string) => {
        console.log(payload)
        setstate(State.LOADING)
        axios
            .post(`/split`, { id: props.provider.id, provider_id: payload.provider_id, provider: payload.provider }, {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': accessToken,
                }
            })
            .then(res => {
                console.log("Get results", res);
                setstate(State.IDLE)
                // Refresh the list to update the split button
            })
            .catch(error => {
                console.log(error)
                setstate(State.ERROR)
            })
    }

    if (redirectToLogin) {
        return <Navigate to={'/login'} />
    }
    let splitRequestButton = <></>
    console.log(props.provider)
    if (state === State.IDLE && !props.provider.audio_file) {
        splitRequestButton = <MdCallSplit
            onClick={() => onRequestSplit(props.provider.provider_id)}
            size={50}
            style={{ cursor: 'pointer' }}
            title="Request split"
        />
    } else if (
        state === State.IDLE && 
        props.provider.audio_file && 
        props.provider.audio_file.status === Status.DONE
    ) {
        splitRequestButton = <Link to={`/splitfire/${props.provider.id}`} aria-current="page">
            <GiPlayButton size={50} style={{ cursor: 'pointer' }} title="Play" />
        </Link>
    } else if (
        state === State.IDLE && 
        props.provider.audio_file && 
        (props.provider.audio_file.status === Status.SPLITTING || props.provider.audio_file.status === Status.DOWNLOADING)
    ) {
        splitRequestButton = <Link to={`/song/votes/${props.provider.id}`} aria-current="page">
            <GiTimeBomb size={50} style={{ cursor: 'pointer' }} title="Waiting for split" />
        </Link>
    }


    if (state === State.LOADING) {
        splitRequestButton = <div>
            <p>Loading...</p>
        </div>
    }

    return (
        <Row className="mb-3 align-items-center">
            <Col xs={9} className="text-start">
                <h4>{props.provider.name}</h4>
                <Image src={`https://img.youtube.com/vi/${props.provider.provider_id}/mqdefault.jpg`} thumbnail />
            </Col>
            <Col xs={3}>{splitRequestButton}</Col>
        </Row >
    )
}