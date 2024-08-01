import { TauriResponse } from "@/app/_src/lib/tauriHandler";
import { SongProvider } from "@/app/_src/models/SongResponse";

export interface ContentCarouselResponse {
    status: TauriResponse,
    message: string,
    audio_files: SongProvider[], // This is missleading, it should be song_providers
}

export interface AccountRegisterResponse {
    status: TauriResponse,
    message: string,
}