use std::fmt::Display;
use serde::{Deserialize, Serialize};
use serde_repr::Serialize_repr;


#[derive(serde::Serialize, serde::Deserialize, Debug, Clone)]
pub struct ResultFile {
    id: i32,
    pub source_file: String,
    pub filename: String,
    pub length: Option<f64>,
    pub onset: Option<Vec<f64>>,
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

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
enum Status {
    #[serde(rename = "downloading")]
    Downloading,
    #[serde(rename = "splitting")]
    Split,
    #[serde(rename = "done")]
    Done,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct AudioFile {
    pub id: i32,
    pub name: String,
    pub status: Status,
    pub results: Vec<ResultFile>,
}

#[derive(Serialize, Deserialize)]
pub struct AudioFileResponse {
    pub code: i32,
    pub message: String,
    pub audio_file: AudioFile,
}

#[derive(Serialize_repr)]
#[repr(u8)]
#[derive(Debug)]
pub enum TauriResponse {
    Error = 0,
    Success = 1,
}

#[derive(Serialize)]
pub struct PreparePlayerResponse {
    pub status: TauriResponse,
    pub message: String,
    pub audio_file_name: Option<String>,
}