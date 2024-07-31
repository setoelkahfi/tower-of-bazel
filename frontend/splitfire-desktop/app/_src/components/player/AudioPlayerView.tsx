import { useContext } from "react";
import { Navigate, useParams } from "react-router-dom";
import AudioPlayer from "./AudioPlayer";
import { UserContext } from "../../lib/CurrentUserContext";

export function AudioPlayerView() {

    const { audioId } = useParams()
    const { user } = useContext(UserContext)

    if (!user) {
        return <Navigate to={'/login'} />
    }

    if (user && audioId) {
        return <AudioPlayer audioId={audioId} />
    }

    return <p>Something wrong</p>
}