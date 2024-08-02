import { AudioFile } from "../components/player/models/AudioFile"

export interface SongResponse {
    code: number,
    message: string,
    name: string,
    album_name: string,
    images: ProviderImage[],
    items: SongProvider[]
}

export interface SongProvider {
    id: number,
    name: string,
    provider_id: string,
    provider_type: ProviderType,
    image_url: string,
    audio_file: AudioFile | null
}

enum ProviderType {
    YOUTUBE = 'youtube',
    SPOTIFY = 'spotify'
}

export interface ProviderImage {
    height: number,
    url: string,
    width: number
}

// Type definitions for Youtube API v3
export interface YoutubeVideo {
    etag: string,
    snippet: YoutubeVideoSnippet
}
export interface YoutubeVideoSnippet {
    videoId: string,
    publishedAt: string,
    channelId: string,
    title: string,
    description: string,
    thumbnails: YoutubeVideoThumbnails,
    channelTitle: string,
    liveBroadcastContent: string,
    publishTime: string
}
export interface YoutubeVideoThumbnails {
    default: YoutubeVideoThumbnail,
    medium: YoutubeVideoThumbnail,
    high: YoutubeVideoThumbnail
}
export interface YoutubeVideoThumbnail {
    url: string,
    width: number,
    height: number
}