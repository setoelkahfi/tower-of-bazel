import { Container, Row, Button } from "react-bootstrap"
import { Link } from "react-router-dom"
import { SearchAutocompleteResult } from "./Home"

interface Prop {
    results: SearchAutocompleteResult[]
}

export default function AutoCompleteView(props: Prop) {
    if (props.results.length === 0) {
        return <></>
    }
    return (
        <Container className="text-start">{props.results.map((result, index) =>
            <Row key={index}>
                <Link to={{ pathname: `/song/${result.id}` }}>
                    <Button className="mb-2">{result.name}</Button>
                </Link>
            </Row>
        )}</Container>
    )
}