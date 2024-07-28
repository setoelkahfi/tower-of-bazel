import axios from "axios"
import { useState, useEffect } from "react"
import { Spinner } from "react-bootstrap"
import { useParams } from "react-router-dom"
import { SongProvider } from "../../../models/SongResponse"
import { SongProviderVote } from "../../../models/SongVotesDetailResponse"
import SongVotesDetailView from "../song/SongVotesDetailView"

enum State {
    LOADING,
    LOADED,
    ERROR
}

enum SFErrorCode {
    NOT_FOUND = 404,
    INTERNAL_SERVER_ERROR = 500
}

interface SFError {
    code: SFErrorCode,
    message: string
}

export enum HTTPStatusCode {
    OK = 200,
    NOT_FOUND = 404,
    INTERNAL_SERVER_ERROR = 500
}

export interface SongBridgeResponse {
    code: HTTPStatusCode,
    message: string,
    error: SFError | null,
    song_provider: SongProvider
    votes: SongProviderVote[]
}

export function SplitDetailView() {

    const { providerId } = useParams()
    const [state, setState] = useState(State.LOADING)
    const [songProvider, setSongProvider] = useState<SongProvider | null>(null)
    const [votes, setVotes] = useState<SongProviderVote[]>([])

    useEffect(() => {
        setState(State.LOADING)
        axios.get(`/song-bridge/${providerId}/detail`)
            .then(res => {
                const response: SongBridgeResponse = res.data
                if (response.code === HTTPStatusCode.OK) {

                    console.log(response)
                    setSongProvider(response.song_provider)
                    setVotes(response.votes)
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
    }, [providerId])

    if (state === State.LOADED && songProvider) {
        return <SongVotesDetailView songProvider={songProvider} votes={votes} />
    }

    if (state === State.LOADING) {
        return <div>
            <Spinner animation="border" role="status">
                <span className="visually-hidden">Loading...</span>
            </Spinner>
        </div>
    }

    return <p>Error</p>
}