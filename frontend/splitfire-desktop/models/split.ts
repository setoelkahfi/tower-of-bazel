import { AudioFile } from "./audio-file"

export interface SplitResponse {
  code: number
  audio_file: AudioFile
  message: string
}