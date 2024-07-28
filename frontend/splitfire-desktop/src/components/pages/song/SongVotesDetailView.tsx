import { Container } from "react-bootstrap"
import { SongProvider } from "../../../models/SongResponse"
import { SongProviderVote } from "../../../models/SongVotesDetailResponse"
import { YoutubeView } from "./components/YoutubeView"
import { TitleView } from "./components/TitleView"
import { UpDownVotesView } from "./components/UpDownVotes"

interface Props {
    songProvider: SongProvider,
    votes: SongProviderVote[]
}

export default function SongVotesDetailView(props: Props) {
    return (
        <Container className="mb-5">
            <TitleView name={props.songProvider.name} />
            <UpDownVotesView votes={props.votes} providerId={props.songProvider.id} audioFile={props.songProvider.audio_file} />
            <YoutubeView provider_id={props.songProvider.provider_id} />
        </Container>
    )
}