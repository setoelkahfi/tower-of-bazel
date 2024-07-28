import { CountDownView } from "./CountDownView"

export function RecordingView(props: { length: number, onRecordingEnd: () => void }) {
    const { length, onRecordingEnd } = props
    return <div>
        <h1>Recording...</h1>
        <CountDownView seconds={length} type="" onCountDownEnd={onRecordingEnd} />
    </div>
}