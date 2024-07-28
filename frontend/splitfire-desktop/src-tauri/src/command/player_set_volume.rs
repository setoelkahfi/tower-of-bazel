use std::fmt::Display;

use crate::players::{BASS_SINK, DRUMS_SINK, OTHER_SINK, VOCALS_SINK};
use log::debug;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize, Debug, PartialEq)]
pub enum Mode {
    #[serde(rename = "vocals")]
    Vocals,
    #[serde(rename = "bass")]
    Bass,
    #[serde(rename = "other")]
    Other,
    #[serde(rename = "drums")]
    Drums,
    Unknown,
}

impl Display for Mode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mode = match self {
            Mode::Vocals => "vocals",
            Mode::Bass => "bass",
            Mode::Other => "other",
            Mode::Drums => "drums",
            Mode::Unknown => "unknown",
        };
        write!(f, "{}", mode)
    }
}

#[tauri::command]
pub fn player_set_volume(mode: Mode, volume: String) {
    // Calcluate volume from 0.0 to 1.0
    let volume = volume.parse::<f32>().unwrap() / 100.0;
    debug!("Setting volume for {:?} to {}.", mode, volume);
    match mode {
        Mode::Vocals => {
            if let Some(sink) = unsafe { VOCALS_SINK.get() } {
                sink.set_volume(volume)
            }
        }
        Mode::Bass => {
            if let Some(sink) = unsafe { BASS_SINK.get() } {
                sink.set_volume(volume)
            }
        }
        Mode::Other => {
            if let Some(sink) = unsafe { OTHER_SINK.get() } {
                sink.set_volume(volume)
            }
        }
        Mode::Drums => {
            if let Some(sink) = unsafe { DRUMS_SINK.get() } {
                sink.set_volume(volume)
            }
        }
        Mode::Unknown => {
            panic!("Should not be here.")
        }
    }
}
