use crate::{
    command::constants::{
        base_url_builder, PATH_ACCOUNT_LOGIN, PATH_ACCOUNT_LOGOUT, PATH_ACCOUNT_PROFILE,
        PATH_ACCOUNT_REGISTER,
    },
    models::{
        account::{
            AccountLoginResponse, AccountProfileResponse, AccountRegisterResponse, ErrorResponse, LoginResponse, ProfileResponse, RegisterResponse
        },
        player::TauriResponse,
    }, rest::try_parsing_error_codes,
};
use crate_error_codes::UserError;
use log::{debug, error};
use reqwest::Client;
use serde_json::json;
use tauri;

#[tauri::command]
pub async fn account_login(username: String, password: String) -> Result<AccountLoginResponse, ErrorResponse> {
    debug!(
        "Logging in with username {}, password {}",
        username, password
    );
    // Login
    let body = json!( {
        "username": username,
        "password": password
    });
    let response = Client::new()
        .post(account_url_builder(PATH_ACCOUNT_LOGIN))
        .json(&body)
        .send()
        .await;

    let ok_response = match response {
        Ok(response) => {
            match response.error_for_status() {
                Ok(ok_response) => ok_response,
                Err(e) => {
                    debug!("Response failed: {:?}", e);
                    return try_parsing_error_codes::<AccountLoginResponse>(response).await;
                }
            }
        },
        Err(e) => {
            debug!("Failed to get response: {:?}", e);
            return Err(ErrorResponse {
                error_code: UserError::NetworkError,
                message: UserError::NetworkError.error_message().to_string(),
            });
        }
    };
    let token = match ok_response.headers().get("Authorization") {
        Some(token) => {
            // Trim Bearer prefix
            let token = match token.to_str() {
                Ok(token) => token.trim_start_matches("Bearer "),
                Err(e) => {
                    error!("Cannot convert token to str: {:?}", e);
                    return Err(ErrorResponse {
                        error_code: UserError::ParseError,
                        message: UserError::ParseError.error_message().to_string(),
                    });
                }
            };
            Some(token.to_string())
        }
        None => {
            error!("No Authorization header found.");
            return Err(ErrorResponse {
                error_code: UserError::ParseError,
                message: UserError::ParseError.error_message().to_string(),
            });
        }
    };
    debug!("Token: {:?}", token);
    let res: LoginResponse = match ok_response.json().await {
        Ok(json) => json,
        Err(e) => {
            error!("Failed to parse response: {:?}", e);
            return Err(ErrorResponse {
                error_code: UserError::ParseError,
                message: UserError::ParseError.error_message().to_string(),
            });
        }
    };
    debug!("Login response: {:?}", res);
    Ok(AccountLoginResponse {
        status: TauriResponse::Success,
        message: res.message,
        access_token: token,
        user: res.user,
    })
}

#[tauri::command]
pub async fn account_logout(access_token: String) {
    debug!("Logging out with access token {}", access_token);
    // Logout
    let response = Client::new()
        .delete(account_url_builder(PATH_ACCOUNT_LOGOUT))
        .header("Authorization", format!("Bearer {}", access_token))
        .send()
        .await;

    match response {
        Ok(response) => {
            debug!("Got response: {:?}", response);
        }
        Err(e) => {
            println!("Failed to get response: {:?}", e);
        }
    }
}

#[tauri::command]
pub async fn account_register(
    name: String,
    email: String,
    password: String,
) -> AccountRegisterResponse {
    debug!("Registering with name {} and email {}.", name, email);
    // Register
    let body = json!( {
        "name": name,
        "email": email,
        "password": password
    });
    let response = Client::new()
        .post(account_url_builder(PATH_ACCOUNT_REGISTER))
        .json(&body)
        .send()
        .await;

    match response {
        Ok(response) => {
            debug!("Got response: {:?}", response);
            let res: RegisterResponse = match response.json().await {
                Ok(json) => json,
                Err(e) => {
                    println!("Failed to parse response: {:?}", e);
                    return AccountRegisterResponse {
                        status: TauriResponse::Error,
                        message: e.to_string(),
                        user: None,
                    };
                }
            };
            debug!("Register response: {:?}", res);
            AccountRegisterResponse {
                status: TauriResponse::Success,
                message: res.message,
                user: res.user,
            }
        }
        Err(e) => {
            println!("Failed to get response: {:?}", e);
            AccountRegisterResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                user: None,
            }
        }
    }
}

#[tauri::command]
pub async fn account_profile(user_id: String) -> AccountProfileResponse {
    debug!("Getting profile for user_id {}", user_id);
    // Get profile
    let url = account_url_builder(PATH_ACCOUNT_PROFILE).replace("{userId}", &user_id);
    let response = Client::new().get(&url).send().await;

    let response = match response {
        Ok(response) => response,
        Err(e) => {
            debug!("Failed to get response: {:?}", e);
            return AccountProfileResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                user: None,
            };
        }
    };
    let res: ProfileResponse = match response.json().await {
        Ok(json) => json,
        Err(e) => {
            debug!("Failed to parse response: {:?}", e);
            return AccountProfileResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                user: None,
            };
        }
    };
    debug!("Profile response: {:?}", res);
    AccountProfileResponse {
        status: TauriResponse::Success,
        message: res.message,
        user: res.user,
    }
}

fn account_url_builder(path: &str) -> String {
    let mut base_url = base_url_builder();
    base_url.add_route(path);
    base_url.build()
}
