use super::player_set_volume::Mode;
use crate::{
    command::player_prepare::prepare_players,
    players::{BASS_SINK, DRUMS_SINK, OTHER_SINK, VOCALS_SINK},
};
use log::info;
use serde::{Deserialize, Serialize};
use std::fmt::Display;

#[derive(Deserialize, Serialize, Debug, PartialEq)]
pub struct PlayerVolume {
    mode: Mode,
    volume: String,
}

impl Display for PlayerVolume {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?} {}", self.mode, self.volume)
    }
}

#[tauri::command]
pub async fn player_paused() {
    info!("Player paused.");

    // Stop all sinks
    if let Some(sink) = unsafe { VOCALS_SINK.get() } {
        sink.pause();
    }
    if let Some(sink) = unsafe { BASS_SINK.get() } {
        sink.pause();
    }
    if let Some(sink) = unsafe { OTHER_SINK.get() } {
        sink.pause();
    }
    if let Some(sink) = unsafe { DRUMS_SINK.get() } {
        sink.pause();
    }
}

#[tauri::command]
pub async fn player_play(player_volumes: Vec<PlayerVolume>) {
    info!("Player resumed. {:?}", player_volumes);

    // Stop all sinks
    if let Some(sink) = unsafe { VOCALS_SINK.get() } {
        player_volumes.iter().for_each(|player_volume| {
            if player_volume.mode == Mode::Vocals {
                let volume = player_volume.volume.parse::<f32>().unwrap() / 100.0;
                sink.set_volume(volume);
            }
        });
        sink.play();
    }
    if let Some(sink) = unsafe { BASS_SINK.get() } {
        player_volumes.iter().for_each(|player_volume| {
            if player_volume.mode == Mode::Bass {
                let volume = player_volume.volume.parse::<f32>().unwrap() / 100.0;
                sink.set_volume(volume);
            }
        });
        sink.play();
    }
    if let Some(sink) = unsafe { OTHER_SINK.get() } {
        player_volumes.iter().for_each(|player_volume| {
            if player_volume.mode == Mode::Other {
                let volume = player_volume.volume.parse::<f32>().unwrap() / 100.0;
                sink.set_volume(volume);
            }
        });
        sink.play();
    }
    if let Some(sink) = unsafe { DRUMS_SINK.get() } {
        player_volumes.iter().for_each(|player_volume| {
            if player_volume.mode == Mode::Drums {
                let volume = player_volume.volume.parse::<f32>().unwrap() / 100.0;
                sink.set_volume(volume);
            }
        });
        sink.play();
    }
}

#[tauri::command]
pub async fn player_stop(audio_id: String) {
    info!("Stopping player.");

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
        sink.stop()
    }
    prepare_players(audio_id).await;
}
