use super::constants::{API_HOST_PRODUCTION, CURRENT_API_HOST};
use crate::{
    command::constants::API_HOST_DEVELOPMENT,
    models::{
        player::TauriResponse,
        settings::{Environment, SetEnvironmentResponse},
    },
};
use log::{debug, warn};

#[tauri::command]
pub fn set_environment(environment: Environment) -> SetEnvironmentResponse {
    debug!("set_environment: {}", environment);
    let api_host = match environment {
        Environment::Development => &API_HOST_DEVELOPMENT,
        Environment::Production => &API_HOST_PRODUCTION,
    };
    debug!("Will set API host to: {}", api_host);
    unsafe {
        let _ = CURRENT_API_HOST.take();
        match CURRENT_API_HOST.set(api_host) {
            Ok(_) => debug!("Did set CURRENT_API_HOST."),
            Err(e) => warn!("Failed to set CURRENT_API_HOST: {:?}", e),
        };
    };

    SetEnvironmentResponse {
        status: TauriResponse::Success,
        message: "CURRENT_API_HOST set done.".to_string(),
    }
}

#[tauri::command]
pub fn get_environment() -> Option<Environment> {
    let env = match api_host() {
        API_HOST_DEVELOPMENT => Environment::Development,
        API_HOST_PRODUCTION => Environment::Production,
        _ => {
            warn!("Unknown api host!!!");
            return None;
        }
    };
    debug!("Current environment: {}", env);
    Some(env)
}

pub fn api_host() -> &'static str {
    match unsafe { CURRENT_API_HOST.get() } {
        Some(host) => {
            debug!("CURRENT_API_HOST: {}", host);
            host
        }
        None => {
            warn!("API host not set. Defaulting to production.");
            API_HOST_PRODUCTION
        }
    }
}
