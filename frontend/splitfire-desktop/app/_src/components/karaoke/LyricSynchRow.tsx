import { useState } from "react";
import { Button, Col, Form, Row } from "react-bootstrap";
import { BsFillTrashFill } from "react-icons/bs";
import LyricSynch from "../../models/lyricSynches";

interface LyricSynchRowProps {
    lyricSynch: LyricSynch
    index: number
    onLyricChange: (lyric: string) => void
    onTimeChange: (time: string) => void
    onRemove: () => void
    processing: boolean
}

export default function LyricSynchRow(props: LyricSynchRowProps) {

    const [lyric, setLyric] = useState(props.lyricSynch.lyric)
    const [time, setTime] = useState(props.lyricSynch.time)

    let removeButton
    if (props.lyricSynch.id < 0) {
        removeButton = <Button onClick={() => props.onRemove() } disabled={props.processing} >
            <BsFillTrashFill color="white" />
        </Button>
    }

    return <Row className="mb-3">
        <Col xs={3}>
            <Form.Control 
                type="text"
                value={time}
                onChange={(e) => {
                    setTime(e.currentTarget.value)
                    props.onTimeChange(e.currentTarget.value)
                }}
                disabled={props.processing}
            />
        </Col>
        <Col xs={8}>
            <Form.Control 
                as="textarea" 
                rows={2} 
                value={lyric} 
                onChange={(e) => {
                    setLyric(e.currentTarget.value)
                    props.onLyricChange(e.currentTarget.value)
                }}
                disabled={props.processing}
            />
        </Col>
        <Col xs={1}>
            {removeButton}
        </Col>
    </Row>
}
interface LyricRowProps {
    lyric: String
}
export function LyricRow(props: LyricRowProps) {

    return <Row>
        <Col>
            {props.lyric}
        </Col>
    </Row>
}