import { YouTubePlayerState } from "./YouTubePlayerState";

export interface YouTubeEventTarget {
    pauseVideo: () => void,
    playVideo: () => void,
    seekTo: (arg0: number) => void,
    getPlayerState: () => YouTubePlayerState,
    getCurrentTime: () => number

}