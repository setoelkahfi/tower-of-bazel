use serde::{Deserialize, Serialize};
use super::player::TauriResponse;

#[derive(Serialize)]
#[derive(Debug)]
pub struct AccountLoginResponse {
  pub status: TauriResponse,
  pub message: String,
  pub access_token: Option<String>,
  pub user: Option<User>,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct LoginResponse {
    code: i32,
    pub message: String,
    pub user: Option<User>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct User {
  id: i32,
  pub email: String,
  pub username: String,
  pub name: String,
  pub gravatar_url: String,
  pub followers_count: i32,
  pub following_count: i32,
  pub about: String
}

#[derive(Serialize)]
#[derive(Debug)]
pub struct AccountRegisterResponse {
  pub status: TauriResponse,
  pub message: String,
  pub user: Option<User>,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct RegisterResponse {
    pub code: i32,
    pub message: String,
    pub user: Option<User>,
}