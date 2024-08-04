import { Result } from "./result";

export enum Status {
    DOWNLOADING = "downloading",    // Requested to process file.
    SPLITTING = "splitting",        // Fresly uploaded file.
    DONE = "done",                  // Done processing file.
}

export interface AudioFile {
    id: number,
    name: string,
    youtube_video_id: string,
    youtube_thumbnail: string,
    status: Status,
    progress: number,
    results: Result[]
}