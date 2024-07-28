import { Container, Row, Col, Form } from "react-bootstrap"
import { ModeDemucs } from "./models/Mode"

export function VolumeSliderView(props: { _onVolumeChange: (mode: ModeDemucs, value: string) => void, isHidden: boolean }) {

    const { _onVolumeChange, isHidden } = props

    return <Container hidden={isHidden} className="mb-3">
        <Row>
          <Col xs={3}>
                <p>Vocals</p>
                <Form.Range onChange={e => _onVolumeChange(ModeDemucs.Vocals, e.target.value) } defaultValue={100}/>
            </Col>
            <Col xs={3}>
                <p>Drums</p>
                <Form.Range onChange={e => _onVolumeChange(ModeDemucs.Drums, e.target.value) }  defaultValue={100} />
            </Col>
            <Col xs={3}>
                <p>Bass</p>
                <Form.Range onChange={e => _onVolumeChange(ModeDemucs.Bass, e.target.value) } defaultValue={100} />
            </Col>
            <Col xs={3}>
                <p>Other</p>
                <Form.Range onChange={e => _onVolumeChange(ModeDemucs.Other, e.target.value) }  defaultValue={100} />
            </Col>
        </Row>
    </Container>
}