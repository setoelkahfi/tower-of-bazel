import { VoteType } from "../components/pages/song/components/UpDownVotes"
import { SongProvider } from "./SongResponse"

export default interface SongVotesDetailResponse {
    code: string
    message: string
    song_provider: SongProvider
    votes: SongProviderVote[]
}

export interface SongProviderVote {
    id: number
    user_id: number
    song_provider_id: number
    vote_type: VoteType
    voter_username_or_id: string
    voter_gravatar: string
    created_at: string
    updated_at: string
}