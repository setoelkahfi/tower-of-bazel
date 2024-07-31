import { Col, Container, Row, Image } from "react-bootstrap"
import { Link } from "react-router-dom"
import { SongProviderVote } from "../../../../models/SongVotesDetailResponse"
import { VoteType } from "./UpDownVotes"

export function VoterGravatarsViews(props: { voters: SongProviderVote[], type: VoteType }) {
    const className = props.type === VoteType.DOWN ? "justify-content-end" : "justify-content-start"
    return (
        <Container>
            <Row className={className}>
                {props.voters.map((x, i) => {
                    return <Col xs={2} key={i} >
                        <Link to={`/@${x.voter_username_or_id}`}>
                            <Image roundedCircle src={x.voter_gravatar} width={24} />
                        </Link>
                    </Col>
                })}
            </Row>
        </Container>
    )
}