import axios from "axios"
import { CSSProperties, useState, useContext } from "react"
import { Row, Col, Spinner } from "react-bootstrap"
import { BsArrowUpCircleFill, BsArrowDownCircleFill, BsPlayBtnFill } from "react-icons/bs"
import { Navigate } from "react-router-dom"
import { UserContext } from "../../../../lib/CurrentUserContext"
import { CurrentUser } from "../../../../lib/db"
import { SongProviderVote } from "../../../../models/SongVotesDetailResponse"
import { AudioFile, Status } from "../../../player/models/AudioFile"
import { HTTPStatusCode, SongBridgeResponse } from "../../esef/SplitFireView"
import { ButtonSplit } from "./ButtonSplit"
import { VoterGravatarsViews } from "./VoterGravatarsViews"

enum State {
  LOADING,
  LOADED,
  ERROR,
}

interface UpDownVotesViewProps {
  providerId: string
  votes: SongProviderVote[]
  audioFile: AudioFile | null
}

export enum VoteType {
  UP = 'up',
  DOWN = 'down'
}

interface VoteState {
  aggregate: number
  buttonUpStyle: CSSProperties
  buttonDownStyle: CSSProperties
  upVotes: SongProviderVote[]
  downVotes: SongProviderVote[]
}

export function UpDownVotesView(props: UpDownVotesViewProps) {

  const [state, setState] = useState(State.LOADED)
  const [goToLogin, setGoToLogin] = useState(false)
  const [goToPlayer, setGoToPlayer] = useState(false)
  const { user } = useContext(UserContext)

  const buttonStyle = (votes: SongProviderVote[], type: VoteType): CSSProperties => {
      if (!user) {
          return { cursor: "pointer" }
      }

      if (type === VoteType.UP) {
          if (shouldDisableButton(votes, VoteType.UP, user)) {
              return { pointerEvents: "none", opacity: "0.4" }
          } else {
              return { cursor: "pointer" }
          }
      } else {
          if (shouldDisableButton(votes, VoteType.DOWN, user)) {
              return { pointerEvents: "none", opacity: "0.4" }
          } else {
              return { cursor: "pointer" }
          }
      }
  }

  const calculateVotes = (votes: SongProviderVote[]): number => {
      if (votes.length === 0) {
          return 0
      }

      const up = votes.filter((x) => x.vote_type === VoteType.UP).length
      const down = votes.filter((x) => x.vote_type === VoteType.DOWN).length
      //console.log('upvotes', up)
      //console.log('downvotes', down)
      const votesAggregate = up - down
      return votesAggregate
  }

  const shouldDisableButton = (votes: SongProviderVote[], type: VoteType, user: CurrentUser) => {
      if (!user) {
          return false
      }
      const x = votes.filter((y) => {
          if (y.user_id === user.user.id && y.vote_type === type)
              return true
          return false
      })
      return x.length > 0
  }

  const [voteState, setVoteState] = useState<VoteState>({
      aggregate: calculateVotes(props.votes),
      buttonUpStyle: buttonStyle(props.votes, VoteType.UP),
      buttonDownStyle: buttonStyle(props.votes, VoteType.DOWN),
      upVotes: props.votes.filter((x) => x.vote_type === VoteType.UP),
      downVotes: props.votes.filter((x) => x.vote_type === VoteType.DOWN)
  })

  const vote = (type: VoteType) => {

      if (!user || !user.accessToken || user.accessToken.length <= 1) {
          setGoToLogin(true)
          return
      }

      setState(State.LOADING)
      axios
          .post(`/song-bridge/${props.providerId}/vote`, { vote_type: type, provider_id: props.providerId },
              {
                  headers: {
                      'Content-Type': 'application/json',
                      'Authorization': user.accessToken,
                  }
              })
          .then(res => {
              const response: SongBridgeResponse = res.data
              //console.log(response.votes)
              if (response.code === HTTPStatusCode.OK) {
                  setVoteState({
                      aggregate: calculateVotes(response.votes),
                      buttonUpStyle: buttonStyle(response.votes, VoteType.UP),
                      buttonDownStyle: buttonStyle(response.votes, VoteType.DOWN),
                      upVotes: response.votes.filter((x) => x.vote_type === VoteType.UP),
                      downVotes: response.votes.filter((x) => x.vote_type === VoteType.DOWN)
                  })
                  setState(State.LOADED)
              } else {
                  console.log('error')
                  setState(State.ERROR)
              }
          })
          .catch(error => {
              console.log(error)
              setState(State.ERROR)
          })
  }

  const isDoneSplitting = props.audioFile && props.audioFile.status === Status.DONE

  if (goToLogin) {
      return <Navigate to={'/login'} />
  }

  if (goToPlayer) {
    return <Navigate to={`/player/${props.audioFile?.id}`} />
}

  if (state === State.LOADING) {
      return <Row className="mb-3" style={{ minHeight: 250 }}>
          <Col className="align-self-center">
              <Spinner animation="border" role="status">
                  <span className="visually-hidden">Loading...</span>
              </Spinner>
          </Col>
      </Row>
  }

  const mainView = isDoneSplitting ? <LetsPlayView onClick={() => setGoToPlayer(true)}/> 
                                   : <MainVotesView voteState={voteState} vote={vote} /> 

  return (
      <Row className="mb-3 mt-3" style={{ minHeight: 250 }}>
          <ButtonSplit providerId={props.providerId} audioFile={props.audioFile} aggregateVotes={voteState.aggregate} />
          {mainView}
      </Row>
  )
}

function LetsPlayView(props: { onClick: () => void }) {

  const { onClick } = props

  return <Col className="align-self-center" xs={12}>
      <BsPlayBtnFill onClick={onClick} size={50} cursor={'pointer'} color="green"/>
  </Col>
}

function MainVotesView(props: { voteState: VoteState, vote: (type: VoteType) => void }) {

  const { voteState, vote } = props

  return <>
      <Col xs={5}>
      <VoterGravatarsViews
          voters={voteState.upVotes}
          type={VoteType.UP}
      />
    </Col>
    <Col xs={2}>
      <BsArrowUpCircleFill
          size={40}
          className="mb-3"
          style={voteState.buttonUpStyle}
          onClick={() => vote(VoteType.UP)}
          color="green"
      />
      <h1 className="votes">{voteState.aggregate}</h1>
      <BsArrowDownCircleFill
          size={40}
          className="mt-3"
          style={voteState.buttonDownStyle}
          onClick={() => vote(VoteType.DOWN)}
          color="green"
      />
    </Col>
    <Col xs={5} className="align-self-end">
      <VoterGravatarsViews
          voters={voteState.downVotes}
          type={VoteType.DOWN}
      />
    </Col>
</>
}