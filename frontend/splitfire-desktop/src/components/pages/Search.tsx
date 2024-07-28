import axios from "axios";
import { useEffect, useState } from "react";
import { Col, Container, Row, Spinner } from "react-bootstrap";
import { useSearchParams } from "react-router-dom";
import { SearchResponse, SearchAutocompleteResult } from "./Home";
import { SearchResultView } from "./SearchResultView";
import { useLogger } from "../../lib/logger";

enum State {
    IDLE,
    LOADED,
    ERROR
}

export default function Search() {

    const log = useLogger('Search')
    const [searchParams] = useSearchParams();
    const [state, setState] = useState(State.IDLE)
    const [searchResults, setSearchResults] = useState<SearchAutocompleteResult[]>([])

    const q = searchParams.get('q')

    useEffect(() => {
        axios
            .get(`/search?q=${q}&ac=false&client=sf-desktop`)
            .then(res => {
                log.debug(res)
                let response: SearchResponse = res.data
                if (response.code === 200) {
                    setState(State.LOADED)
                    setSearchResults(response.results)
                } else {
                    setState(State.ERROR)
                }
            })
            .catch(error => {
                log.error(error)
                setState(State.ERROR)
            })

    })

    let resultView: JSX.Element = <div>
        <Spinner animation='grow' variant="danger"></Spinner>
    </div>
    let title = `Searching '${q}'...`

    if (state === State.ERROR) {
        resultView = <div>
            <p>Something went wrong.</p>
        </div>
    }

    if (state === State.LOADED) {
        resultView = <SearchResultView results={searchResults} />
        title = `Results for '${q}'.`
    }

    return (
        <Container className="mb-5">
            <Row className="mb-3">
                <Col>
                    <h1>{title}</h1>
                </Col>
            </Row>
            <Row className="mb-3">
                <Col>
                    {resultView}
                </Col>
            </Row>
        </Container>
    )
}