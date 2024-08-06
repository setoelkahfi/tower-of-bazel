use crate::models::account::ErrorResponse;
use crate_error_codes::ErrorCode;
use log::{debug, error};
use reqwest::Response;

pub mod account;
pub mod content;

async fn parse_error_response<T>(response: Response) -> Result<T, ErrorResponse> {
    let e: ErrorResponse = match response.json().await {
        Ok(json) => json,
        Err(e) => {
            //debug!("Received text: {:?}", response.text().await);
            //return Err(ErrorResponse { 
            //    error_code: ErrorCode::InvalidRequest, 
            //    message: "test".to_string()
            //});
            error!("Failed to parse error response: {:?}", e);
            return Err(ErrorResponse {
                error_code: ErrorCode::ParseError,
                message: e.to_string(),
            });
        }
    };
    debug!("Error response: {:?}", e);
    return Err(e);
}
