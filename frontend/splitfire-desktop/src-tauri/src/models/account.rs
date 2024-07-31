use serde::{Deserialize, Serialize};
use super::player::TauriResponse;

#[derive(Serialize)]
#[derive(Debug)]
pub struct AccountLoginResponse {
  status: TauriResponse,
  message: String,
  user: Option<User>,
}

#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub struct LoginResponse {
    code: i32,
    message: String,
    user: User,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct User {
  id: i32,
  email: String,
  username: String,
  name: String,
  gravatar_url: String,
  followers_count: i32,
  following_count: i32,
  about: String
}