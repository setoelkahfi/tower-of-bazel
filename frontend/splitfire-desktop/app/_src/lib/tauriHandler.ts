export const TAURI_DOWNLOAD_RESULT_FILES = 'download_result_files'

// Player commands
export const TAURI_PLAYER_PREPARE = 'player_prepare'
export const TAURI_PLAYER_SET_VOLUME = 'player_set_volume'
export const TAURI_PLAYER_UNMOUNT = 'player_unmount'
export const TAURI_PLAYER_RECORD = 'player_record'
export const TAURI_PLAYER_RECORD_STOP = 'player_record_stop'
export const TAURI_PLAYER_PLAY = 'player_play'
export const TAURI_PLAYER_PAUSED = 'player_paused'
export const TAURI_PLAYER_RESUMED = 'player_resumed'
export const TAURI_PLAYER_STOP = 'player_stop'
export const TAURI_PLAYER_RECORDING_LENGTH = 'player_recording_length'  // in seconds       

// Account
export const TAURI_ACCOUNT_LOGIN = 'account_login'
export const TAURI_ACCOUNT_LOGOUT = 'account_logout'
export const TAURI_ACCOUNT_REGISTER = 'account_register'

// Contents
export const TAURI_CONTENT_CAROUSEL = 'content_carousel'

export enum TauriResponse {
    ERROR = 0,
    SUCCESS = 1
}

// Response from the Tauri API
export interface PlayerPrepareResponse {
    status: TauriResponse,
    message: string,
    audio_file_name?: string,
}