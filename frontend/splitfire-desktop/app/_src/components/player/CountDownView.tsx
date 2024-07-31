import { useEffect } from "react"
import { useCountDown } from "../../lib/useCountDown"
import { Col, Row } from "react-bootstrap"

export function CountDownView(props: { seconds: number, type: string, onCountDownEnd?: () => void}) {
    const { secondsLeft, startTimer } = useCountDown()

    useEffect(() => {
        startTimer(props.seconds)
    }, [])

    if (secondsLeft === 0 && props.onCountDownEnd) {
        console.log('CountDownView: onCountDownEnd')
        props.onCountDownEnd()
    }

    const displayText = secondsLeft === 0 ? props.type : secondsLeft

    return <Row>
        <Col className="align-self-center" xs={12}>
            <h1>{displayText}</h1>
        </Col>
    </Row>
}