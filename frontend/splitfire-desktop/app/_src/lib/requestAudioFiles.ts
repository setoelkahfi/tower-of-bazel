import axios from "./axios"

export default function requestAudioFiles(audioFileId: string): Promise<any> {
    return axios.get(`/splitfire/${audioFileId}`)
}