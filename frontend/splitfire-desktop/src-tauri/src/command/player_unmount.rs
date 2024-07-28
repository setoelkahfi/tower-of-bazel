use crate::players::{
    BASS_FILE, BASS_SINK, DRUMS_FILE, DRUMS_SINK, OTHER_FILE, OTHER_SINK, VOCALS_FILE, VOCALS_SINK,
};
use log::info;

#[tauri::command]
pub async fn player_unmount() {
    info!("Unmounting player.");

    // Stop all sinks
    if let Some(sink) = unsafe { VOCALS_SINK.take() } {
        sink.stop();
    }
    if let Some(sink) = unsafe { BASS_SINK.take() } {
        sink.stop();
    }
    if let Some(sink) = unsafe { OTHER_SINK.take() } {
        sink.stop();
    }
    if let Some(sink) = unsafe { DRUMS_SINK.take() } {
        sink.stop();
    }

    // Dereference result files
    if let (Some(_), Some(_), Some(_), Some(_)) = (
        unsafe { VOCALS_FILE.take() },
        unsafe { DRUMS_FILE.take() },
        unsafe { BASS_FILE.take() },
        unsafe { OTHER_FILE.take() },
    ) {
        info!("Unmounting result files done.");
    }
}
