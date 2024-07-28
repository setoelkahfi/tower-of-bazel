import { useEffect, useState } from "react"
import { SongProvider } from "../../../models/SongResponse"
import axios from "axios"
import { FormattedMessage } from "react-intl"
import { Button, Carousel, Col, Row, Spinner } from "react-bootstrap"
import { Link } from "react-router-dom"

enum State {
    LOADING,
    LOADED,
    ERROR
}

export default function TopVotesView() {

    const [state, setState] = useState(State.LOADING)
    const [files, setFiles] = useState<SongProvider[]>([])

    useEffect(() => {
        setState(State.LOADING)
        axios.get(`/top-votes`)
            .then(res => {
                const files = res.data.audio_files;
                console.log(files)
                setFiles(files)
                setState(State.LOADED)
            })
            .catch(error => {
                console.log(error)
                setState(State.ERROR)
            })
    }, [])

    if (state === State.LOADING) {
        return <div>
            <p>
                <FormattedMessage id="home.loading"
                    defaultMessage="Loading top votes..."
                    description="Loading top votes message" />
            </p>
            <Spinner animation='grow' variant="danger"></Spinner>
        </div>
    }

    if (state === State.ERROR) {
        return <></>
    }

    return (
        <div>
            <Row>
                <Col xs={4}>
                    <p className="h3">Top Votes</p>
                </Col>
            </Row>
            <Row>
                <Carousel>
                    {files.map((file) => (
                        <Carousel.Item key={file.id} style={{ padding: '20px' }}>
                            <img
                                className="d-block w-100"
                                src={file.image_url}
                                alt="First slide"
                            />
                            <Carousel.Caption>
                                <Link to={{ pathname: `/split/${file.id}` }}>
                                    <Button variant="dark">{file.name}</Button>
                                </Link>
                            </Carousel.Caption>
                        </Carousel.Item>
                    ))}
                </Carousel>
            </Row>
        </div>
    )

}