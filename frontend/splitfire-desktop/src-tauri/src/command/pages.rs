use tauri::{AppHandle, WindowBuilder, WindowUrl};

#[tauri::command]
pub async fn open_lyrics_editor(handle: AppHandle, path: String) {
    let url = format!("http://localhost:3002{}", path);
    let docs_window = WindowBuilder::new(
        &handle,
        "lyrics_editor", /* the unique window label */
        WindowUrl::App(url.parse().unwrap()),
    )
    .build()
    .unwrap();
    let _ = docs_window.set_title("Lyrics Editor");
}

#[tauri::command]
pub async fn open_player(handle: AppHandle, path: String) {
    print!("{path}");
    let url = format!("http://localhost:3002{}", path);
    let docs_window = WindowBuilder::new(
        &handle,
        "page_search", /* the unique window label */
        WindowUrl::App(url.parse().unwrap()),
    )
    .build()
    .unwrap();
    let _ = docs_window.set_title("Search");
}
