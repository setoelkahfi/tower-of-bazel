import { Col, Row } from "react-bootstrap"
import YouTube, { Options } from "react-youtube"

export function YoutubeView(props: { provider_id: string }) {
    const opts: Options = {
        width: '100%',
        playerVars: {
            // https://developers.google.com/youtube/player_parameters
            autoplay: 0,
            mute: 0,
            controls: 0,
            rel: 0,
            showinfo: 0
        },
    }
    return (
        <Row className="mt-5">
            <Col>
                <YouTube
                    videoId={props.provider_id}
                    opts={opts}
                />
            </Col>
        </Row>
    )
}