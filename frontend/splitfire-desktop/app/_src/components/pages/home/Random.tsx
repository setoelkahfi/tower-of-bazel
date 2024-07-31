import axios from "axios";
import { useEffect, useState } from "react";
import { Button, Carousel, Col, Row, Spinner } from "react-bootstrap";
import { FormattedMessage } from "react-intl";
import { Link } from "react-router-dom";
import { SongProvider } from "../../../models/SongResponse";
import { useLogger } from "../../../lib/logger";
import ErrorView from "../../templates/Error";

enum State {
    LOADING,
    LOADED,
    ERROR
}

export default function RandomView() {

    const log = useLogger('CarouselView')
    const [state, setState] = useState(State.LOADING)
    const [files, setFiles] = useState<SongProvider[]>([])

    useEffect(() => {
        setState(State.LOADING)
        axios.get(`/carousel`)
            .then(res => {
                const files = res.data.audio_files;
                log.debug(files)
                setFiles(files)
                setState(State.LOADED)
            })
            .catch(error => {
                log.error(error)
                setState(State.ERROR)
            })
    }, [])

    if (state === State.LOADING) {
        return <div>
            <p>
                <FormattedMessage id="home.loading"
                    defaultMessage="Loading SplitFire AI..."
                    description="Loading message" />
            </p>
            <Spinner animation='grow' variant="danger"></Spinner>
        </div>
    }

    if (state === State.ERROR) {
        return <ErrorView errorMessage="Something went wrong..." />
    }

    if (files.length === 0) {
        return <div>
            No content found
        </div>
    }

    return (
        <div>
            <Row>
                <Col xs={4}>
                    <p className="h3">Random</p>
                </Col>
            </Row>
            <Carousel>
                {files.slice(0, 5).map(item => (
                    <Carousel.Item key={item.id} style={{ padding: '20px' }}>
                        <img
                            className="d-block w-100"
                            src={item.image_url}
                            alt="First slide"
                        />
                        <Carousel.Caption>
                            <Link to={{ pathname: `/split/${item.id}` }}>
                                <Button variant="dark">{item.name}</Button>
                            </Link>
                        </Carousel.Caption>
                    </Carousel.Item>
                ))}
            </Carousel>
        </div>
    )
}