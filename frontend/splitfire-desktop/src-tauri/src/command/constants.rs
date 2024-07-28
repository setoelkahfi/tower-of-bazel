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

pub fn base_url_builder() -> URLBuilder {
    let mut url_builder = URLBuilder::new();
    url_builder
        .set_protocol("https")
        .set_host(API_HOST)
        .add_param("client_id", SF_CLIENT_ID)
        .add_param("client_secret", SF_CLIENT_SECRET);
    url_builder
}
