import { Col, Row } from "react-bootstrap"
import { BsPlayBtnFill, BsStopBtnFill, BsFillRecordBtnFill, BsPauseBtnFill } from "react-icons/bs"

export function ControlButtonsView(props: { isPlaying: boolean, isRecording: boolean, onClick: () => void, onStop: () => void, onRecord: () => void }) {

  const { isPlaying, isRecording, onClick, onStop, onRecord } = props

  const _onPlayOrPause = () => {
    if (isRecording) return

    onClick()
  }

  return <Row>
      <Col xs={{span: 1, offset: 4}} className="mb-3 mt-3" color="red" >
        { isPlaying ? <BsPauseBtnFill onClick={_onPlayOrPause} size={32} style={ { cursor: isRecording ? undefined : "pointer"}} title="Pause" color={ isRecording ? "grey" : "white"}  />
                    : <BsPlayBtnFill onClick={_onPlayOrPause} size={32} style={ { cursor: isRecording ? undefined : "pointer"}} title="Play" color={ isRecording ? "grey" : "white" } />
        }
      </Col>
      <Col xs={{span: 1}} className="mb-3 mt-3">
        <BsStopBtnFill 
          onClick={() => {
            if (isRecording) return

            onStop()
          }}
          size={32} 
          style={{ cursor: isRecording ? undefined : "pointer"}} 
          title="Stop"
          color={ isRecording ? "grey" : "white" }
        />
      </Col>
      <Col xs={{span: 1}} className="mb-3 mt-3">
        <BsFillRecordBtnFill
          onClick={onRecord}
          size={32} 
          style={{ cursor: "pointer"}} 
          title={ isRecording ? "Stop" : "Record"}
          color={ isRecording ? "green" : "red" }
        />
      </Col>
  </Row>
}
