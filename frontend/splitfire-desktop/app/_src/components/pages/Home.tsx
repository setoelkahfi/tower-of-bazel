import { Component, ReactNode } from "react"
import { Container, Row } from "react-bootstrap";
import RandomView from "./home/Random";
import SearchView from "./home/SearchFormView";
import TopVotesView from "./home/TopVotesView";
import ReadyToPlayView from "./home/ReadyToPlay";

type HomeProps = {}

type HomeState = {}

export interface SearchAutocompleteResult {
    name: string
    id: string
    title: string
}

export interface SearchResponse {
    code: number
    message: string
    results: SearchAutocompleteResult[]
}

class Home extends Component<HomeProps, HomeState> {

    constructor(props: HomeProps) {
        super(props)
        this.state = {}
    }

    render(): ReactNode {
        return (
            <Container className="mb-5">
                <Row className="mb-3">
                    <SearchView />
                </Row>
                <Row className="mb-3">
                    <ReadyToPlayView />
                </Row>
                <Row className="mb-3">
                    <RandomView />
                </Row>
                <Row className="mb-3">
                    <TopVotesView />
                </Row>
            </Container >
        )
    }
}

export default Home