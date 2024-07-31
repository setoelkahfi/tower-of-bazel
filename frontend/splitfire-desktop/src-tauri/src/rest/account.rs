use log::debug;
use reqwest::Client;
use serde_json::json;
use tauri;
use crate::{command::constants::{base_url_builder, PATH_ACCOUNT_LOGIN, PATH_ACCOUNT_REGISTER}, models::{account::{AccountLoginResponse, LoginResponse}, player::TauriResponse}};

#[tauri::command]
pub async fn account_login(username: String, password: String) -> AccountLoginResponse {
    debug!("Logging in with username {}, password {}", username, password);
    // Login
    let body = json!( {
        "username": username,
        "password": password
    });
    let response = Client::new()
        .post(login_url_builder())
        .json(&body)
        .send()
        .await;

    match response {
        Ok(response) => {
            let token = match response.headers().get("Authorization") {
                Some(token) => {
                    // Trim Bearer prefix
                    let token = match token.to_str() {
                        Ok(token) => {
                            token.trim_start_matches("Bearer ")
                        },
                        Err(e) => {
                            println!("Failed to get token: {:?}", e);
                            return AccountLoginResponse {
                                status: TauriResponse::Error,
                                message: "Failed to get token".to_string(),
                                access_token: None,
                                user: None
                            };
                        }
                    };
                    Some(token.to_string())
                },
                None => {
                    println!("Failed to get token");
                    return AccountLoginResponse {
                        status: TauriResponse::Error,
                        message: "Failed to get token".to_string(),
                        access_token: None,
                        user: None
                    };
                }
            };
            let res: LoginResponse = match response.json().await {
                Ok(json) => {
                    json
                },
                Err(e) => {
                    println!("Failed to parse response: {:?}", e);
                    return AccountLoginResponse {
                        status: TauriResponse::Error,
                        message: "Failed to parse response".to_string(),
                        access_token: None,
                        user: None
                    };
                }
            };

            debug!("Login response: {:?}", res);
            AccountLoginResponse {
                status: TauriResponse::Success,
                message: res.message,
                access_token: token,
                user: res.user
            }
        }
        Err(e) => {
            println!("Failed to get response: {:?}", e);
            AccountLoginResponse {
                status: TauriResponse::Error,
                message: "Failed to get response".to_string(),
                access_token: None,
                user: None
            }
        }
    }
}

#[tauri::command]
pub async fn account_register(username: String, email: String, password: String) {
    debug!("Registering with username {} and email {}.", username, email);
    // Register
    let body = json!( {
        "username": username,
        "email": email,
        "password": password
    });
    let response = Client::new()
        .post(register_url_builder())
        .json(&body)
        .send()
        .await;

    match response {
        Ok(response) => {
            debug!("Got response: {:?}", response);
            let res: LoginResponse = match response.json().await {
                Ok(json) => json,
                Err(e) => {
                    println!("Failed to parse response: {:?}", e);
                    return;
                }
            };
            debug!("Register response: {:?}", res);
        }
        Err(e) => {
            println!("Failed to get response: {:?}", e);
        }
    }
}

fn login_url_builder() -> String {
    let mut base_url = base_url_builder();
    base_url.add_route(PATH_ACCOUNT_LOGIN);
    base_url.build()
}

fn register_url_builder() -> String {
    let mut base_url = base_url_builder();
    base_url.add_route(PATH_ACCOUNT_REGISTER);
    base_url.build()
}