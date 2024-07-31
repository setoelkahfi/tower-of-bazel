import { Row, Col, Container } from "react-bootstrap"
import { SearchAutocompleteResult } from "./Home"

interface Props {
    results: SearchAutocompleteResult[]
}
export function SearchResultView(props: Props) {

    let resultView
    if (props.results.length === 0) {
        resultView = <Row>
            <Col>No results...</Col>
        </Row>
    } else {
        resultView = <div>
            {
                props.results.map(result => (
                    <Row>
                        <Col>{result.title}</Col>
                    </Row>
                ))
            }
        </div>
    }

    return (
        <Container>
            {resultView}
        </Container>
    )
}