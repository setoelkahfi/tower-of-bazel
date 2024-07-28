import debounce from "lodash.debounce";
import { Form, Row, Col, Button, Alert, Spinner } from "react-bootstrap";
import { SearchAutocompleteResult, SearchResponse } from "../Home";
import { useState } from "react";
import axios from "axios";
import AutoCompleteView from "../AutoCompleteView";
import { Navigate } from "react-router-dom";

enum State {
    IDLE,
    TO_SEARCH,
    LOADING,
    LOADED,
    ERROR
}

export default function SearchView() {

    const [state, setState] = useState(State.IDLE)
    const [query, setQuery] = useState('')
    const [searchResults, setSearchResults] = useState<SearchAutocompleteResult[]>([])
    const [errorMessage, setErrorMessage] = useState('')
    const [validQ, setValidQ] = useState(false)

    const debouncedSearch = debounce(async (query: string) => {
        setState(State.LOADING)
        axios
            .get(`/search?q=${query}&ac=true&client=sf-desktop`)
            .then(res => {
                //console.log(res)
                let response: SearchResponse = res.data

                console.log(response)
                if (res.status === 200) {
                    setSearchResults(response.results)
                    setState(State.LOADED)
                } else {
                    setState(State.ERROR)
                }
            })
            .catch(error => {
                console.log(error)
                setState(State.ERROR)
            })
    }, 300); // 300ms is the debounce delay

    const onChange = (query: string) => {
        if (query.length === 0) {
            setErrorMessage('Query is required')
            setValidQ(false)
            return
        }
        if (query.length < 3) {
            setErrorMessage('Query must be at least 3 characters')
            setValidQ(false)
            return
        }
        setValidQ(true)
        setQuery(query)
        debouncedSearch(query)
    }

    const onSubmit = () => {
        console.log('onSubmit')
        setState(State.TO_SEARCH)
    }

    if (state === State.TO_SEARCH) {
        return <Navigate to={`/search?q=${query}`} />
    }

    let validationText = <></>
    if (state === State.ERROR) {
        validationText = <Alert variant="danger" onClose={() => setErrorMessage('')} dismissible><p>{errorMessage}</p></Alert>
    }

    let autoCompleteView = <></>
    if (state === State.LOADING) {
        autoCompleteView = <Spinner animation='grow' variant="info"></Spinner>
    } else if (state === State.LOADED) {
        autoCompleteView = <AutoCompleteView results={searchResults} />
    }

    return (
        <Form onSubmit={(e) => e.preventDefault()}>
            <Row>
                <Col xs={8}>
                    <Form.Control
                        placeholder="Search song..."
                        className="mb-3"
                        onChange={(e) => onChange(e.target.value)}
                    />
                    {validationText}
                    {autoCompleteView}
                </Col>
                <Col xs={{ span: 3, offset: 1 }}>
                    <Button variant="primary" onClick={() => onSubmit()} disabled={!validQ}>Search</Button>
                </Col >
            </Row>
        </Form >
    )
}