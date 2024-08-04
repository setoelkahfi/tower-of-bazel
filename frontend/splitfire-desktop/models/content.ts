import { SongProvider } from "@/models/SongResponse";
import { TauriResponse } from "./shared";
import { SongProviderVote } from "@/models/SongVotesDetailResponse";

// Need to be renamed into more generic name
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

export interface SongProviderResponse {
    status: TauriResponse,
    message: string,
    song_provider: SongProvider
    votes: SongProviderVote[]
}