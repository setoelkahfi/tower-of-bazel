use super::{
    constants::{base_url_builder, PATH_AUDIO},
    download_result_files::{save_result_files, ResultFile},
};
use crate::{
    command::{
        download_result_files::{download_result_files, get_provider_id_dir_path},
        player_set_volume::Mode,
    },
    get_soundcard,
    players::{BASS_SINK, DRUMS_SINK, OTHER_SINK, VOCALS_SINK},
    record::record_instrument::AudioDevice,
};
use log::{debug, error, info};
use reqwest::Client;
use rodio::{Decoder, DeviceTrait, OutputStream, Sink};
use serde::{Deserialize, Serialize};
use serde_repr::*;
use std::{
    fs::{self, DirEntry, File},
    io::BufReader,
    path::{Path, PathBuf},
};
use tauri::async_runtime::spawn;

#[derive(Serialize, Deserialize)]
enum Status {
    #[serde(rename = "downloading")]
    Downloading,
    #[serde(rename = "splitting")]
    Split,
    #[serde(rename = "done")]
    Done,
}

#[derive(Serialize, Deserialize)]
struct AudioFile {
    id: i32,
    name: String,
    status: Status,
    results: Vec<ResultFile>,
}

#[derive(Serialize, Deserialize)]
struct AudioFileResponse {
    code: i32,
    message: String,
    audio_file: AudioFile,
}

#[derive(Serialize_repr)]
#[repr(u8)]
enum TauriResponse {
    Error = 0,
    Success = 1,
}

#[derive(Serialize)]
pub struct PreparePlayerResponse {
    status: TauriResponse,
    message: String,
    audio_file_name: Option<String>,
}

#[tauri::command]
pub async fn player_prepare(provider_id: String) -> PreparePlayerResponse {
    debug!("Preparing player for provider_id {}.", provider_id);

    // Get audio file response
    let response = Client::new()
        .get(build_audio_detail_url(provider_id))
        .send()
        .await;

    match response {
        Ok(response) => {
            debug!("Got response: {:?}", response);
            let res: AudioFileResponse = match response.json().await {
                Ok(audio_file) => audio_file,
                Err(e) => {
                    error!("Failed to parse response: {:?}", e);
                    return PreparePlayerResponse {
                        status: TauriResponse::Error,
                        message: e.to_string(),
                        audio_file_name: None,
                    };
                }
            };

            prepare_result_files(res.audio_file).await
        }
        Err(e) => {
            error!("Failed to get response: {:?}", e);
            PreparePlayerResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                audio_file_name: None,
            }
        }
    }
}

async fn prepare_result_files(audio_file: AudioFile) -> PreparePlayerResponse {
    save_result_files(&audio_file.id.to_string(), &audio_file.results).await;
    download_result_files(audio_file.id.to_string(), audio_file.results).await;
    prepare_players(audio_file.id.to_string()).await;
    PreparePlayerResponse {
        status: TauriResponse::Success,
        message: "Success".to_string(),
        audio_file_name: Some(audio_file.name),
    }
}

fn build_audio_detail_url(id: String) -> String {
    let mut url_builder = base_url_builder();
    url_builder.add_route(PATH_AUDIO);
    url_builder.add_route(&id);
    url_builder.build()
}

pub async fn prepare_players(audio_id: String) {
    info!("Preparing player audio files: {}", audio_id);

    // Check if we have the ~/.sfai/audio/{audio_id} folder
    let audio_dir_path: PathBuf = match get_provider_id_dir_path(&audio_id).await {
        Ok(path) => path,
        Err(e) => {
            info!("Failed to get audio directory: {:?}", e);
            return;
        }
    };

    // get the files in the directory
    let dir_entries = if let Ok(paths) = fs::read_dir(audio_dir_path) {
        paths
    } else {
        info!("Failed to read audio directory.");
        return;
    };

    let get_path = |dir_entry: Result<DirEntry, std::io::Error>| -> Option<PathBuf> {
        debug!("Getting path to audio file.");
        let dir_entry = match dir_entry {
            Ok(dir_entry) => dir_entry,
            Err(e) => {
                info!("Failed to get dir entry: {:?}", e);
                return None;
            }
        };
        Some(dir_entry.path())
    };

    let sink = |path: &Path| -> Option<(Mode, Sink)> {
        debug!("Playing: {:?}", path);
        let device = if let Ok(device) = get_soundcard(AudioDevice::Output, true) {
            device
        } else {
            info!("Failed to get soundcard output.");
            return None;
        };

        if let Ok(name) = device.name() {
            info!("Output device is: {}", name);
        }

        let (_stream, handle) = if let Ok(x) = OutputStream::try_from_device(&device) {
            x
        } else {
            info!("Failed to get output stream.");
            return None;
        };

        let sink = if let Ok(z) = Sink::try_new(&handle) {
            z
        } else {
            info!("Failed to get sink.");
            return None;
        };

        let file = if let Ok(f) = File::open(path) {
            f
        } else {
            info!("Failed to open file.");
            return None;
        };

        match Decoder::new(BufReader::new(file)) {
            Ok(decoder) => {
                sink.append(decoder);
                sink.pause();
                Some((get_mode(path), sink))
            }
            Err(e) => {
                info!("Failed to create decoder: {:?}", e);
                None
            }
        }
    };

    let file_paths = dir_entries
        .into_iter()
        .flat_map(get_path)
        .collect::<Vec<_>>();

    file_paths
        .into_iter()
        .filter_map(|x| {
            // Only play .wav
            if let Some("wav") = x.extension().and_then(|x| x.to_str()) {
                Some(x)
            } else {
                None
            }
        })
        .map(|x| {
            spawn(async move {
                let sink = sink(&x);
                persist_sinks(sink)
            })
        })
        .for_each(drop);
}

fn persist_sinks(sink: Option<(Mode, Sink)>) {
    // Return early if we don't have a sink
    let (mode, sink) = match sink {
        Some(x) => x,
        None => return,
    };
    match mode {
        Mode::Vocals => {
            info!("Persisting vocals sink.");
            let _ = unsafe { VOCALS_SINK.set(sink) };
        }
        Mode::Bass => {
            info!("Persisting bass sink.");
            let _ = unsafe { BASS_SINK.set(sink) };
        }
        Mode::Other => {
            info!("Persisting other sink.");
            let _ = unsafe { OTHER_SINK.set(sink) };
        }
        Mode::Drums => {
            info!("Persisting drums sink.");
            let _ = unsafe { DRUMS_SINK.set(sink) };
        }
        Mode::Unknown => {
            error!("Got an unkown mode.");
            panic!("Should not be here.")
        }
    }
}

fn get_mode(path: &Path) -> Mode {
    if let Some(file_name) = path.file_name() {
        if let Some(file_name) = file_name.to_str() {
            return get_mode_from_filename(file_name);
        } else {
            return Mode::Unknown;
        }
    }
    Mode::Unknown
}

pub fn get_mode_from_filename(filename: &str) -> Mode {
    if filename.contains("vocal") {
        Mode::Vocals
    } else if filename.contains("drums") {
        Mode::Drums
    } else if filename.contains("bass") {
        Mode::Bass
    } else if filename.contains("other") {
        Mode::Other
    } else {
        Mode::Unknown
    }
}
