import { useParams } from "react-router-dom"
import KaraokePlayer from "./KaraokePlayer"
import { useCurrentUser } from "./KaraokeView"

export function KaraokePlayerView() {

    const { audioFileId } = useParams()
    const { currentUser } = useCurrentUser()

    if (currentUser && audioFileId) {
        return <KaraokePlayer audioFileId={audioFileId} currentUser={currentUser} />
    }

    return <p>Something wrong</p>
}