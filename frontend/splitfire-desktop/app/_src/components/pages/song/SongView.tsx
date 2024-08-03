import axios from "axios";
import { useCallback, useEffect, useState } from "react"
import { Col, Container, Image, Row, Spinner } from "react-bootstrap";
import { FormattedMessage } from "react-intl";
import { useParams } from "react-router-dom";
import { SongResponse } from "../../../models/SongResponse";
import SongViewItems from "./SongViewItems";
import SongViewConnectProvider from "./SongViewConnectProvider";
import { useLogger } from "../../../../../lib/logger";

export interface Payload {
    reference_id: string
    provider_id: string
    name: string
    provider: string
}

enum State {
    LOADING,
    LOADED,
    ERROR,
    NEED_UPDATE
}

export function SongView() {

    const log = useLogger('SongView')
    // Reference ID
    const { audioId } = useParams() as { audioId: string }
    const [state, setState] = useState(State.LOADING)
    const [songResponse, setSongResponse] = useState<SongResponse | null>(null)

    const fetchSong = useCallback(() => {
        setState(State.LOADING)
        axios.get(`/song-bridge/${audioId}`)
            .then(res => {
                log.debug(res)
                const response: SongResponse = res.data;
                log.debug(response)
                setSongResponse(response)
                setState(State.LOADED)
            })
            .catch(error => {
                log.error(error)
                setState(State.ERROR)
            })

    }, [audioId])

    useEffect(() => {
        fetchSong()
    }, [audioId, fetchSong])

    const onAddedProvider = (payload: Payload) => {
        fetchSong()
    }

    let mainView = <></>
    if (state === State.LOADING) {
        mainView = <div>
            <p>
                <FormattedMessage id="song.loading"
                    defaultMessage="Searching for songs..."
                    description="Loading message" />
            </p>
            <Spinner animation='grow' variant="warning"></Spinner>
        </div>
    }

    if (state === State.ERROR) {
        mainView = <div>
            <p>
                <FormattedMessage id="song.error"
                    defaultMessage="Something wrong..."
                    description="Loading message" />
            </p>
        </div>
    }
    if (state === State.LOADED && songResponse) {
        const { name, album_name, images, items } = songResponse
        log.debug(items)
        let topView = <></>
        if (songResponse?.items.length > 0) {
            topView = <SongViewItems items={items} referenceId={audioId} />
        } else {
            topView = <Row className="mb-3">
                <Col>
                    <p>
                        <FormattedMessage id="song.no_results"
                            defaultMessage="No results found."
                            description="No results message" />
                    </p>
                </Col>
            </Row>
        }
        let imageView = <></>
        if (images.length > 0) {
            imageView = <Image
                className="w-100"
                src={images[0].url}
                alt="Image of the song"
            />
        }

        mainView = <>
            <Row className="mb-3">
                <Col xs={4}>
                    {imageView}
                </Col>
                <Col xs={8}>
                    <h1>{name}</h1>
                    <h2>{album_name}</h2>
                </Col>
            </Row>
            {topView}
            <SongViewConnectProvider name={name} referenceId={audioId} onAddedProvider={onAddedProvider} />
        </>
    }

    return (
        <Container className="mb-5">
            {mainView}
        </Container>
    )
}