use serde::{Deserialize, Serialize};
use super::player::{AudioFile, TauriResponse};

#[derive(Serialize)]
#[derive(Debug)]
pub struct ContentCarouselResponse {
  pub status: TauriResponse,
  pub message: String,
  pub audio_files: Vec<SongProvider>,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct CarouselResponse {
    pub code: i32,
    pub message: String,
    pub audio_files: Vec<SongProvider>,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct SongProvider {
  pub id: i32,
  pub name: String,
  pub provider_id: String,
  pub provider_type: ProviderType,
  pub image_url: String,
  pub audio_file: Option<AudioFile>
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub enum ProviderType {
  #[serde(rename = "youtube")]
  Youtube,
  #[serde(rename = "spotify")]
  Spotify,
}