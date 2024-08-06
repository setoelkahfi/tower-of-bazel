use serde_repr::{Deserialize_repr, Serialize_repr};
use ts_rs::TS;

#[derive(TS)]
#[ts(export)]
#[derive(Serialize_repr, Deserialize_repr)]
#[repr(i32)]
#[derive(Debug)]
pub enum ErrorCode {
    // User defined error codes starts from 1000
    UserNotFound = 1000,
    InvalidCredentials = 1001,

    // Generic error codes starts from 1
    InvalidRequest = 1,
    ParseError = 2,
    NetworkError = 3,
}

impl ErrorCode {
    pub fn error_message(&self) -> &str {
        match self {
            ErrorCode::UserNotFound => "User not found.",
            ErrorCode::InvalidRequest => "Invalid request.",
            ErrorCode::ParseError => "Failed to parse response.",
            ErrorCode::NetworkError => "Failed to get response.",
            ErrorCode::InvalidCredentials => "Invalid credentials.",
        }
    }
    
}