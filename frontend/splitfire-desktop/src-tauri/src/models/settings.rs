use serde::{Deserialize, Serialize};
use super::player::TauriResponse;

#[derive(Serialize, Deserialize)]
pub struct SetEnvironmentResponse {
  pub status: TauriResponse,
  pub message: String,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub enum Environment {
    #[serde(rename = "development")]
    Development,
    #[serde(rename = "production")]
    Production,
}

impl std::fmt::Display for Environment {
  fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
      let env = match self {
          Environment::Development => "development",
          Environment::Production => "production",
      };
      write!(f, "{}", env)
  }
}
