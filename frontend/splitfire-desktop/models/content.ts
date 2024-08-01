import { SongProvider } from "@/app/_src/models/SongResponse";
import { TauriResponse } from "./shared";

export interface ContentCarouselResponse {
    status: TauriResponse,
    message: string,
    audio_files: SongProvider[], // This is missleading, it should be song_providers
}

export interface AccountRegisterResponse {
    status: TauriResponse,
    message: string,
}

// Response from the Tauri API
export interface PlayerPrepareResponse {
    status: TauriResponse,
    message: string,
    audio_file_name?: string,
}