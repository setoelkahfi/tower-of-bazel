use serde::{Deserialize, Serialize};
use ts_rs::TS;

#[derive(TS)]
#[ts(export)]
#[repr(i32)]
#[derive(Serialize, Deserialize)]
#[derive(Debug)]
pub enum UserError {
    // User defined error codes starts from 1000
    UserNotFound = 1000,
    InvalidCredentials = 1001,

    // Generic error codes starts from 1
    InvalidRequest = 1,
    ParseError = 2,
    NetworkError = 3,
}

impl UserError {
    pub fn error_message(&self) -> &str {
        match self {
            UserError::UserNotFound => "User not found.",
            UserError::InvalidRequest => "Invalid request.",
            UserError::ParseError => "Failed to parse response.",
            UserError::NetworkError => "Failed to get response.",
            UserError::InvalidCredentials => "Invalid credentials.",
        }
    }
    
}