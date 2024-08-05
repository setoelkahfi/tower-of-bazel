use crate::models::account::ErrorResponse;
use crate_error_codes::UserError;
use log::error;
use reqwest::Response;

pub mod account;
pub mod content;

async fn try_parsing_error_codes<T>(response: Response) -> Result<T, ErrorResponse> {
    let e: ErrorResponse = match response.json().await {
        Ok(json) => json,
        Err(e) => {
            error!("Failed to parse error response: {:?}", e);
            return Err(ErrorResponse {
                error_code: UserError::ParseError,
                message: e.to_string(),
            });
        }
    };
    return Err(e);
}
