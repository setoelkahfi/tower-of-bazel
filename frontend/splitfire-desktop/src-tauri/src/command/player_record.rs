use crate::{
    command::player_controls::player_play,
    players::BASS_FILE,
    record::record_instrument::{record_instrument, send_signal_to_stop, DEFAULT_LENGTH, DEFAULT_LENGTH_TOLERANCE},
};
use log::info;

use super::player_controls::PlayerVolume;

#[tauri::command]
pub async fn player_record(audio_id: String, user_id: i32, player_volumes: Vec<PlayerVolume>) {
    // Get audio file response
    player_play(player_volumes).await;

    // Do the recording
    record_instrument(audio_id, user_id).await;
}

#[tauri::command]
pub async fn player_record_stop() {
    info!("Stopping recording.");
    send_signal_to_stop();
}

#[tauri::command]
pub async fn player_recording_length() -> f64 {
    info!("Get bass file length.");
    if let Some(result_file) = unsafe { BASS_FILE.get() } {
        if let Some(length) = result_file.length {
            // Round upwards to the nearest second
            let rounded_length = length.ceil();
            return rounded_length + DEFAULT_LENGTH_TOLERANCE;
        }
        DEFAULT_LENGTH
    } else {
        DEFAULT_LENGTH
    }
}
