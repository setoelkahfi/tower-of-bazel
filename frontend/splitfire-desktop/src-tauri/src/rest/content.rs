use crate::{
    command::constants::{base_url_builder, PATH_CAROUSEL, PATH_READY_TO_PLAY},
    models::{
        content::{CarouselResponse, ContentCarouselResponse},
        player::TauriResponse,
    },
};
use log::{debug, error};
use reqwest::Client;

#[tauri::command]
pub async fn content_carousel() -> ContentCarouselResponse {
    let response = Client::new()
        .get(content_url_builder(PATH_CAROUSEL))
        .send()
        .await;

    let response = match response {
        Ok(response) => response,
        Err(e) => {
            error!("Failed to get response: {:?}", e);
            return ContentCarouselResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                audio_files: vec![],
            };
        }
    };
    let res: CarouselResponse = match response.json().await {
        Ok(json) => json,
        Err(e) => {
            error!("Failed to parse response: {:?}", e);
            return ContentCarouselResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                audio_files: vec![],
            };
        }
    };
    debug!("Carousel response: {:?}", res);
    ContentCarouselResponse {
        status: TauriResponse::Success,
        message: res.message,
        audio_files: res.audio_files,
    }
}

#[tauri::command]
pub async fn content_ready_to_play() -> ContentCarouselResponse {
    let response = Client::new()
        .get(content_url_builder(PATH_READY_TO_PLAY))
        .send()
        .await;

    let response = match response {
        Ok(response) => response,
        Err(e) => {
            debug!("Failed to get response: {:?}", e);
            return ContentCarouselResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                audio_files: vec![],
            };
        }
    };
    let res: CarouselResponse = match response.json().await {
        Ok(json) => json,
        Err(e) => {
            debug!("Failed to parse response: {:?}", e);
            return ContentCarouselResponse {
                status: TauriResponse::Error,
                message: e.to_string(),
                audio_files: vec![],
            };
        }
    };

    debug!("Ready to play: {:?}", res);
    ContentCarouselResponse {
        status: TauriResponse::Success,
        message: res.message,
        audio_files: res.audio_files,
    }
}

fn content_url_builder(path: &str) -> String {
    let mut url_builder = base_url_builder();
    url_builder.add_route(path);
    url_builder.build()
}
