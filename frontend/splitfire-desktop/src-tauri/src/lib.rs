use log::{debug, error, info};
use record::record_instrument::AudioDevice;
use rodio::{
    cpal::{default_host, traits::HostTrait},
    Device, DeviceTrait,
};
use std::{fs::create_dir_all, path::PathBuf};

pub mod command;
pub mod players;
pub mod record;
pub mod rest;
pub mod models;

#[cfg(debug_assertions)]
const HOME_DIR: &str = ".sfai-dev";
#[cfg(not(debug_assertions))]
const HOME_DIR: &str = ".sfai";

const AUDIO_DIR: &str = "audio";

// Get ~/.sfai directory
pub fn sfai_home_dir_path() -> Option<PathBuf> {
    match home::home_dir() {
        Some(path) => {
            info!("Home directory: {}", path.to_str().unwrap());
            let home_dir_path = path.join(HOME_DIR);
            if home_dir_path.exists() && home_dir_path.is_file() {
                return Some(home_dir_path);
            }
            // CREATE DIRECTORY
            //create_dir_all(path.join(".smb"))?;
            let _ = create_dir_all(path.join(HOME_DIR));
            Some(home_dir_path)
        }
        None => {
            error!("Failed to get home directory. So strange.");
            None
        }
    }
}

// Create audio directory if it doesn't exist
pub fn audio_dir_path() -> Option<PathBuf> {
    if let Some(home_dir_path) = sfai_home_dir_path() {
        let audio_dir_path = home_dir_path.join(AUDIO_DIR);
        if audio_dir_path.exists() && audio_dir_path.is_file() {
            return Some(audio_dir_path);
        }
        // CREATE DIRECTORY
        let _ = create_dir_all(home_dir_path.join(AUDIO_DIR));
        Some(audio_dir_path)
    } else {
        None
    }
}

// Get the soundcard device or the default device if fallback is true.
pub fn get_soundcard(
    device_type: AudioDevice,
    fallback_to_default: bool,
) -> Result<Device, anyhow::Error> {
    let host = default_host();
    // Get list of all input devices including soundcards, microphones, etc.
    let devices = match device_type {
        AudioDevice::Input => host.input_devices()?,
        AudioDevice::Output => host.output_devices()?,
    };
    // Select output device scarlett 2i2
    let device = match devices.into_iter().find(|x| match x.name() {
        Ok(n) => {
            info!("{} name: {}", device_type, n);
            n.contains("Scarlett 2i2")
        }
        Err(e) => {
            error!("Failed to get device name: {}", e);
            false
        }
    }) {
        Some(d) => d,
        None => {
            if fallback_to_default {
                let devices = match device_type {
                    AudioDevice::Input => host.default_input_device(),
                    AudioDevice::Output => host.default_output_device(),
                };

                if let Some(device) = devices {
                    debug!("Fallback to default {}.", device_type);
                    return Ok(device);
                }
            }
            let message = format!("Failed to find {}.", device_type);
            return Err(anyhow::Error::msg(message));
        }
    };
    Ok(device)
}
