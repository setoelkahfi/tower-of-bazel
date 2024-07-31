import { AudioFile } from "../components/player/models/AudioFile"
import axios from "./axios"

export default function requestSplitService(providerId: string, accessToken: string): Promise<any> {
    return axios.post(`/split`, { provider_id: providerId },
    {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': accessToken,
        }
    })
}

export interface SplitResponse {
    code: number
    audio_file: AudioFile
    message: string
}