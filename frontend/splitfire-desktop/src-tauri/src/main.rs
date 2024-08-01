#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]
use app::{
    command::{
        pages::{__cmd__open_lyrics_editor, __cmd__open_player, open_lyrics_editor, open_player},
        player_controls::{
            __cmd__player_paused, __cmd__player_play, __cmd__player_stop, player_paused,
            player_play, player_stop,
        },
        player_prepare::{__cmd__player_prepare, player_prepare},
        player_record::{
            __cmd__player_record, __cmd__player_record_stop, __cmd__player_recording_length,
            player_record, player_record_stop, player_recording_length,
        },
        player_set_volume::{__cmd__player_set_volume, player_set_volume},
        player_unmount::{__cmd__player_unmount, player_unmount},
    },
    rest::{
        account::{
            __cmd__account_login, __cmd__account_logout, __cmd__account_register, account_login,
            account_logout, account_register,
        },
        content::{
            __cmd__content_carousel, __cmd__content_ready_to_play,
            __cmd__content_song_bridge_detail, content_carousel, content_ready_to_play,
            content_song_bridge_detail,
        },
    },
    sfai_home_dir_path,
};
use tauri_plugin_log::fern::colors::{Color, ColoredLevelConfig};
use tauri_plugin_store::StoreBuilder;

fn main() {
    // Create ~/.sfai directory if it doesn't exist
    sfai_home_dir_path();

    tauri::Builder::default()
        .plugin(
            tauri_plugin_log::Builder::default()
                .with_colors(
                    ColoredLevelConfig::default()
                        .debug(Color::Green)
                        .info(Color::Cyan),
                )
                .build(),
        )
        .plugin(tauri_plugin_store::Builder::default().build())
        .setup(|app| {
            let mut store = StoreBuilder::new(app.handle(), "splitfire.bin".parse()?).build();
            match store.load() {
                Ok(_) => {
                    println!("Store loaded successfully.");
                }
                Err(e) => {
                    println!("Failed to load store: {:?}", e);
                }
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            account_login,
            account_logout,
            account_register,
            open_lyrics_editor,
            open_player,
            player_record,
            player_record_stop,
            player_prepare,
            player_set_volume,
            player_unmount,
            player_paused,
            player_play,
            player_stop,
            player_recording_length,
            content_carousel,
            content_ready_to_play,
            content_song_bridge_detail,
        ])
        .run(tauri::generate_context!())
        .expect("Error while running tauri application.");
}
