use crate::{
    command::constants::{
        base_url_builder, PATH_CAROUSEL, PATH_READY_TO_PLAY, PATH_SONG_BRIDGE_DETAIL, PATH_TOP_VOTES,
    },
    models::{
        content::{
            CarouselResponse, ContentCarouselResponse, ContentSongBridgeResponse,
            SongBridgeResponse,
        },
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

#[tauri::command]
pub async fn content_song_bridge_detail(song_provider_id: String) -> ContentSongBridgeResponse {
    debug!("Song provider id: {:?}", song_provider_id);
    let url =
        content_url_builder(PATH_SONG_BRIDGE_DETAIL).replace("{providerId}", &song_provider_id);
    let response: Result<reqwest::Response, reqwest::Error> = Client::new().get(url).send().await;

    let response = match response {
        Ok(response) => response,
        Err(e) => {
            error!("Failed to get response: {:?}", e);
            return ContentSongBridgeResponse {
                code: TauriResponse::Error,
                message: e.to_string(),
                song_provider: None,
                votes: vec![],
            };
        }
    };

    let res: SongBridgeResponse = match response.json().await {
        Ok(json) => json,
        Err(e) => {
            error!("Failed to parse response: {:?}", e);
            return ContentSongBridgeResponse {
                code: TauriResponse::Error,
                message: e.to_string(),
                song_provider: None,
                votes: vec![],
            };
        }
    };

    debug!("Song bridge detail: {:?}", res);

    let votes = match res.votes {
        Some(votes) => votes,
        None => vec![],
    };

    ContentSongBridgeResponse {
        code: TauriResponse::Success,
        message: res.message,
        song_provider: res.song_provider,
        votes,
    }
}

#[tauri::command]
pub async fn content_top_voted() -> ContentCarouselResponse {
    let response = Client::new()
        .get(content_url_builder(PATH_TOP_VOTES))
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
    debug!("Top voted response: {:?}", res);
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
