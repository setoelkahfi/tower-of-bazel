import { AudioFile } from "../components/player/models/AudioFile"

export interface SongResponse {
    code: number,
    message: string,
    name: string,
    album_name: string,
    images: ProviderImage[],
    items: SongProvider[]
}
/*
{
    "id": 1571,
        "user_id": 1,
            "song_id": 641,
                "provider_id": "EYACy7jELw4",
                    "provider_type": "youtube",
                        "name": "Arjuna",
                            "preview_url": null,
                                "created_at": "2022-11-23T12:56:56.623Z",
                                    "updated_at": "2022-11-23T12:56:56.623Z",
                                        "album_provider_id": 1,
                                            "artist_provider_id": null,
                                                "path": "/songs-bridge/arjuna-1571",
                                                    "type": "Song bridge",
                                                        "created": "6 months ago"
}
*/
export interface SongProvider {
    id: string,
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