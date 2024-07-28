use crate::command::download_result_files::ResultFile;
use hound::WavWriter;
use once_cell::sync::OnceCell;
use rodio::Sink;
use std::{
    fs::File,
    io::BufWriter,
    sync::{mpsc::Sender, Arc, Mutex},
};

pub static mut VOCALS_SINK: OnceCell<Sink> = OnceCell::new();
pub static mut DRUMS_SINK: OnceCell<Sink> = OnceCell::new();
pub static mut BASS_SINK: OnceCell<Sink> = OnceCell::new();
pub static mut OTHER_SINK: OnceCell<Sink> = OnceCell::new();

pub static mut VOCALS_FILE: OnceCell<ResultFile> = OnceCell::new();
pub static mut DRUMS_FILE: OnceCell<ResultFile> = OnceCell::new();
pub static mut BASS_FILE: OnceCell<ResultFile> = OnceCell::new();
pub static mut OTHER_FILE: OnceCell<ResultFile> = OnceCell::new();

pub type RecordingWriter = Arc<Mutex<Option<WavWriter<BufWriter<File>>>>>;
pub static mut RECORDING_WRITER: OnceCell<RecordingWriter> = OnceCell::new();
pub static mut RECORDING_SENDER: OnceCell<Sender<()>> = OnceCell::new();
