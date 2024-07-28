use crate::{
    audio_dir_path,
    command::player_prepare::get_mode_from_filename,
    players::{BASS_FILE, DRUMS_FILE, OTHER_FILE, VOCALS_FILE},
};
use anyhow::anyhow;
use futures::future;
use log::{debug, error, info, warn};
use reqwest::{Client, Error, Response};
use std::{
    fmt::Display,
    fs::{create_dir_all, File, OpenOptions},
    io::Write,
    path::{Path, PathBuf},
};

use super::player_set_volume::Mode;

#[derive(serde::Serialize, serde::Deserialize, Debug, Clone)]
pub struct ResultFile {
    id: i32,
    source_file: String,
    filename: String,
    pub length: Option<f64>,
    onset: Option<Vec<f64>>,
}

impl Display for ResultFile {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{{ id: {}, source_file: {}, filename: {}, length: {:?}, onset: {:?} }}",
            self.id, self.source_file, self.filename, self.length, self.onset
        )
    }
}

pub async fn save_result_files(audio_file_id: &String, result_files: &[ResultFile]) {
    // Check if we have ~/.sfai/audio/{provider_id} folder and create it if not
    let audio_id_path = match get_provider_id_dir_path(audio_file_id).await {
        Ok(path) => path,
        Err(e) => {
            error!("Failed to get audio directory: {:?}", e);
            return;
        }
    };

    // Write length and onset to result file's filename.json
    let x = result_files
        .iter()
        .map(|result_file| {
            persist_result_file(result_file.clone());
            let filename = format!("{}.json", result_file.filename);
            let file = get_result_file(&audio_id_path, &filename, true);
            async move {
                match file {
                    Ok(mut file) => {
                        let _ =
                            file.write_all(serde_json::to_string(&result_file).unwrap().as_bytes());
                    }
                    Err(e) => {
                        error!("Failed to get file: {:?}", e);
                    }
                }
            }
        })
        .collect::<Vec<_>>();

    let _ = future::join_all(x).await;
    info!("Saved audio analysis.");
}

fn persist_result_file(result_file: ResultFile) {
    debug!("Persisting result file: {}", result_file);
    let mode = get_mode_from_filename(&result_file.filename);
    match mode {
        Mode::Vocals => {
            let _ = unsafe { VOCALS_FILE.set(result_file) };
        }
        Mode::Bass => {
            let _ = unsafe { BASS_FILE.set(result_file) };
        }
        Mode::Other => {
            let _ = unsafe { OTHER_FILE.set(result_file) };
        }
        Mode::Drums => {
            let _ = unsafe { DRUMS_FILE.set(result_file) };
        }
        Mode::Unknown => {
            error!("Unknown mode.");
        }
    }
}

pub async fn download_result_files(provider_id: String, result_files: Vec<ResultFile>) {
    // Check if we have ~/.sfai/audio/{provider_id} folder and create it if not
    let provider_id_path = match get_provider_id_dir_path(&provider_id).await {
        Ok(path) => path,
        Err(e) => {
            error!("Failed to get audio directory: {:?}", e);
            return;
        }
    };

    batch_download(result_files, provider_id_path).await;
}

async fn batch_download(result_files: Vec<ResultFile>, provider_id_path: PathBuf) {
    // Download files in parallel and store them in the ~/.sfai/audio/{provider_id} folder
    info!("Batch downloading {:?} result files.", result_files.len());

    let download_file = |result_file: ResultFile| {
        info!("Downloading file: {:?}", result_file.source_file);
        let task = async {
            let response = Client::new().get(result_file.source_file).send().await;

            match response {
                Ok(response) => {
                    info!("Got response: {:?}", response);
                    Ok(response)
                }
                Err(e) => {
                    error!("Failed to get response: {:?}", e);
                    Err(e)
                }
            }
        };

        // Create file in ~/.sfai/audio/{provider_id} folder
        let file = get_result_file(&provider_id_path, &result_file.filename, true);

        (task, file)
    };

    let (tasks, files): (Vec<_>, Vec<_>) = result_files
        .into_iter()
        .filter(|x| {
            debug!("Length: {:?}", x.length);
            debug!("Onset: {:?}", x.onset);
            should_download_file(&provider_id_path, x.filename.clone())
        })
        .map(download_file)
        .unzip();

    let results = future::join_all(tasks).await;

    let store_result = |x: (Result<Response, Error>, Result<File, std::io::Error>)| async {
        //info!("Storing result: {:?}, {:?}", x.0, x.1);

        // make sure both are Oks
        let (result, file) = match (x.0, x.1) {
            (Ok(result), Ok(file)) => {
                info!("Got result and file.");
                info!("Result: {:?}", result.url());
                info!("File: {:?}", file);
                (result, file)
            }
            _ => {
                error!("Failed to get result and file.");
                return;
            }
        };
        // Write bytes to file
        let _ = write_bytes_to_file(file, result).await;
    };

    // Map result and file to store_result
    let store_results = results
        .into_iter()
        .zip(files)
        .map(|x| async {
            debug!("Storing result: {:?}, {:?}", x.0, x.1);
            let _ = store_result(x).await;
        })
        .collect::<Vec<_>>();

    let _ = future::join_all(store_results).await;

    info!("Batch download done.");
}

// Check if we should download the file.
// If we have the ~/.sfai/audio/{provider_id} folder, then we should not download the result files again.
pub async fn get_provider_id_dir_path(provider_id: &String) -> anyhow::Result<PathBuf> {
    if let Some(audio_dir_path) = audio_dir_path() {
        let provider_dir_path = audio_dir_path.join(provider_id.clone());
        if provider_dir_path.exists() && provider_dir_path.is_dir() {
            return Ok(provider_dir_path);
        }
        // CREATE DIRECTORY
        let _ = create_dir_all(audio_dir_path.join(provider_id));
        Ok(provider_dir_path)
    } else {
        error!("Failed to get audio directory.");
        Err(anyhow!("Failed to get audio directory."))
    }
}

fn get_result_file(
    provider_id_path: &Path,
    filename: &String,
    should_create_file: bool,
) -> Result<File, std::io::Error> {
    OpenOptions::new()
        .create(should_create_file)
        .write(true)
        .read(true)
        .open(provider_id_path.join(filename))
}

fn should_download_file(provider_id_path: &Path, filename: String) -> bool {
    match get_result_file(provider_id_path, &filename, false) {
        Ok(file) => {
            warn!(
                "File already exists: {:?}",
                &provider_id_path.join(filename)
            );
            // Check if file is not empty
            let metadata = file.metadata();
            match metadata {
                Ok(metadata) => {
                    if metadata.len() > 0 {
                        warn!("File is not empty. We should not download it.");
                        return false;
                    }
                    debug!("File is empty. We should download it.");
                    true
                }
                Err(e) => {
                    error!("Failed to get metadata: {:?}", e);
                    true
                }
            }
        }
        Err(e) => {
            debug!(
                "Could not find a result file {:?}: {:?}",
                &provider_id_path.join(filename),
                e.to_string()
            );
            true
        }
    }
}

// Write reqwest::Response bytes to file.
async fn write_bytes_to_file(mut file: File, response: Response) -> Result<(), std::io::Error> {
    info!("Writing bytes to: {:?}", file);

    match response.bytes().await {
        Ok(bytes) => match file.write_all(&bytes) {
            Ok(_) => {
                info!("Wrote bytes to file.");
                Ok(())
            }
            Err(e) => {
                error!("Failed to write bytes to file: {:?}", e);
                Err(e)
            }
        },
        Err(e) => {
            error!("Failed to get bytes: {:?}", e);
            Err(std::io::Error::new(
                std::io::ErrorKind::Other,
                "Failed to get bytes.",
            ))
        }
    }
}
