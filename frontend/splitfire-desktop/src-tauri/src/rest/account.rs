use log::debug;
use reqwest::Client;
use serde_json::json;
use tauri;
use crate::{command::constants::{base_url_builder, PATH_ACCOUNT_LOGIN, PATH_ACCOUNT_REGISTER}, models::account::LoginResponse};

#[tauri::command]
pub async fn account_login(username: String, password: String) {
    debug!("Logging in with username {}.", username);
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
            debug!("Got response: {:?}", response);
            let res: LoginResponse = match response.json().await {
                Ok(json) => json,
                Err(e) => {
                    println!("Failed to parse response: {:?}", e);
                    return;
                }
            };
            debug!("Login response: {:?}", res);
        }
        Err(e) => {
            println!("Failed to get response: {:?}", e);
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