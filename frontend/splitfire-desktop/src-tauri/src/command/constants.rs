use url_builder::URLBuilder;

// Client ID and Client Secret
#[cfg(debug_assertions)]
pub const SF_CLIENT_ID: &str = "cli";
#[cfg(not(debug_assertions))]
pub const SF_CLIENT_ID: &str = "cli";
#[cfg(debug_assertions)]
pub const SF_CLIENT_SECRET: &str = "secretttttttt";
#[cfg(not(debug_assertions))]
pub const SF_CLIENT_SECRET: &str = "secretttttttt";

// BASE_URL
#[cfg(debug_assertions)]
pub const API_HOST: &str = "localhost:3001";
#[cfg(not(debug_assertions))]
pub const API_HOST: &str = "api.musik88.com";

// Paths
pub const PATH_AUDIO: &str = "api/v1/splitfire";

// Account Paths
pub const PATH_ACCOUNT_LOGIN: &str = "api/v1/login";
pub const PATH_ACCOUNT_REGISTER: &str = "api/v1/register";
pub const PATH_ACCOUNT_LOGOUT: &str = "api/v1/logout";
pub const PATH_ACCOUNT_PROFILE: &str = "api/v1/profile/{userId}";

// Contents Paths
pub const PATH_CAROUSEL: &str = "api/v1/carousel";
pub const PATH_READY_TO_PLAY: &str = "api/v1/ready-to-play";
pub const PATH_SEARCH: &str = "api/v1//search";
pub const PATH_TOP_VOTES: &str = "api/v1/top-votes";
pub const PATH_SONG_BRIDGE_DETAIL: &str = "api/v1/song-bridge/{providerId}/detail";

pub fn base_url_builder() -> URLBuilder {
    let mut url_builder = URLBuilder::new();
    url_builder
        .set_protocol("https")
        .set_host(API_HOST)
        .add_param("client_id", SF_CLIENT_ID)
        .add_param("client_secret", SF_CLIENT_SECRET);
    url_builder
}
