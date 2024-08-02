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
  pub id: i32, // API response code
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

#[derive(Serialize)]
#[derive(Debug)]
pub struct ContentSongBridgeResponse {
  pub code: TauriResponse,
  pub message: String,
  pub song_provider: Option<SongProvider>,
  pub votes: Vec<SongProviderVote>
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct SongBridgeResponse {
    pub code: i32, // API response code
    pub message: String,
    pub error: Option<String>,
    pub song_provider: Option<SongProvider>,
    pub votes: Option<Vec<SongProviderVote>>
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct SongProviderVote {
  pub id: i32,
  pub user_id: i32,
  pub song_provider_id: i32,
  pub vote_type: VoteType,
  pub voter_username_or_id: String,
  pub voter_gravatar: String,
  pub created_at: String,
  pub updated_at: String
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub enum VoteType {
  #[serde(rename = "up")]
  UP,
  #[serde(rename = "down")]
  DOWN
}
