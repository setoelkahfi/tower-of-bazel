use crate::{
    command::{download_result_files::get_provider_id_dir_path, player_set_volume::Mode},
    get_soundcard,
    players::{BASS_FILE, RECORDING_SENDER, RECORDING_WRITER},
};
use chrono::Utc;
use cpal::{
    traits::{DeviceTrait, StreamTrait},
    FromSample, Sample, SampleFormat, SupportedStreamConfig,
};
use hound::WavWriter;
use log::{debug, error, info};
use rodio::cpal;
use std::thread::spawn;
use std::{
    fmt::Display,
    fs::{create_dir_all, File},
    io::BufWriter,
    sync::{mpsc::channel, Arc, Mutex},
    thread::sleep,
    time::Duration,
};

pub enum AudioDevice {
    Input,
    Output,
}

impl Display for AudioDevice {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AudioDevice::Input => write!(f, "Input device"),
            AudioDevice::Output => write!(f, "Output device"),
        }
    }
}

fn sample_format(format: SampleFormat) -> hound::SampleFormat {
    if format.is_float() {
        hound::SampleFormat::Float
    } else {
        hound::SampleFormat::Int
    }
}

fn wav_spec_from_config(config: &SupportedStreamConfig) -> hound::WavSpec {
    hound::WavSpec {
        channels: config.channels() as _,
        sample_rate: config.sample_rate().0 as _,
        bits_per_sample: (config.sample_format().sample_size() * 8) as _,
        sample_format: sample_format(config.sample_format()),
    }
}

pub type WavWriterHandle = Arc<Mutex<Option<WavWriter<BufWriter<File>>>>>;

fn write_input_data<T, U>(input: &[T], writer: &WavWriterHandle)
where
    T: Sample,
    U: Sample + hound::Sample + FromSample<T>,
{
    if let Ok(mut guard) = writer.try_lock() {
        if let Some(writer) = guard.as_mut() {
            for &sample in input.iter() {
                let sample: U = U::from_sample(sample);
                writer.write_sample(sample).ok();
            }
        }
    }
}

pub const DEFAULT_LENGTH: f64 = 599.0;
// Is this needed?
pub const DEFAULT_LENGTH_TOLERANCE: f64 = 1.0;

pub async fn record_instrument(audio_id: String, user_id: i32) {
    info!("Start recording: audio_id:{} user_id:{}", audio_id, user_id);
    // Find devices.
    let input_device = if let Ok(device) = get_soundcard(AudioDevice::Input, true) {
        device
    } else {
        info!("Failed to get soundcard input.");
        return;
    };

    if let Ok(name) = input_device.name() {
        info!("Input device is: {}", name);
    }

    let input_config = match input_device.default_input_config() {
        Ok(c) => c,
        Err(e) => {
            error!("failed to find input config: {}", e);
            return;
        }
    };

    // The WAV file we're recording to.
    let recording_path = match get_recording_path(audio_id, user_id.to_string(), Mode::Bass).await {
        Ok(path) => path,
        Err(e) => {
            error!("failed to get audio directory: {}", e);
            return;
        }
    };
    debug!("Recording path: {}", recording_path);
    let spec = wav_spec_from_config(&input_config);
    let writer = match WavWriter::create(&recording_path, spec) {
        Ok(w) => w,
        Err(e) => {
            error!("Failed to create wav writer: {}", e);
            return;
        }
    };
    let writer = Arc::new(Mutex::new(Some(writer)));

    // Run the input stream on a separate thread.
    let input_stream_writer = writer.clone();

    let err_fn = move |err| {
        error!("an error occurred on stream: {}", err);
    };

    let stream = match input_config.sample_format() {
        SampleFormat::I8 => input_device.build_input_stream(
            &input_config.into(),
            move |data, _: &_| write_input_data::<i8, i8>(data, &input_stream_writer),
            err_fn,
            None,
        ),

        SampleFormat::I16 => input_device.build_input_stream(
            &input_config.into(),
            move |data, _: &_| write_input_data::<i16, i16>(data, &input_stream_writer),
            err_fn,
            None,
        ),
        SampleFormat::I32 => input_device.build_input_stream(
            &input_config.into(),
            move |data, _: &_| write_input_data::<i32, i32>(data, &input_stream_writer),
            err_fn,
            None,
        ),
        SampleFormat::F32 => input_device.build_input_stream(
            &input_config.into(),
            move |data, _: &_| write_input_data::<f32, f32>(data, &input_stream_writer),
            err_fn,
            None,
        ),
        _ => {
            error!("unsupported sample format");
            return;
        }
    };

    let stream = match stream {
        Ok(s) => s,
        Err(e) => {
            error!("failed to build input stream: {}", e);
            return;
        }
    };

    let _ = stream.play();

    // Take the audio length in seconds
    // Get result file bass' length

    let length_with_tolerance = if let Some(bass_file) = unsafe { BASS_FILE.get() } {
        if let Some(length) = bass_file.length {
            length + DEFAULT_LENGTH_TOLERANCE
        } else {
            DEFAULT_LENGTH
        }
    } else {
        DEFAULT_LENGTH
    };
    debug!("Recording for {} seconds", length_with_tolerance);

    // Create channel to stop recording
    let (send, recv) = channel::<()>();

    // Persist writer and sender
    unsafe {
        let _ = RECORDING_WRITER.set(writer);
    };
    unsafe {
        let _ = RECORDING_SENDER.set(send);
    };

    // Wait for recording to finish
    spawn(move || {
        // Sleep for length of recording
        // Add 5 seconds from original recording length so that the original thread can stop the recording
        if recv
            .recv_timeout(std::time::Duration::from_secs_f64(length_with_tolerance))
            .is_ok()
        {
            info!("Recording stopped abruptly.");
            stop_recording();
            return;
        }
        let _ = recv.recv();
    });

    // See if we can actually do this
    sleep(Duration::from_secs_f64(length_with_tolerance));
    info!("Recording stopped from the original thread.");
    send_signal_to_stop();
}

pub fn send_signal_to_stop() {
    if let Some(sender) = unsafe { RECORDING_SENDER.get() } {
        let _ = sender.send(());
    }
}

fn stop_recording() {
    info!("Stopping recording.");
    // Get writer from oncecell
    if let Ok(mut guard) = unsafe { RECORDING_WRITER.get().unwrap().lock() } {
        if let Some(writer) = guard.take() {
            writer.finalize().ok();
            info!("Recording complete!");
        }
    } else {
        info!("Failed to finalize writer.");
    };
}

// Get string path to audio directory
async fn get_recording_path(
    audio_id: String,
    user_id: String,
    mode: Mode,
) -> anyhow::Result<String> {
    let audio_dir_path = if let Ok(path) = get_provider_id_dir_path(&audio_id).await {
        path
    } else {
        return Err(anyhow::Error::msg("failed to get audio directory"));
    };

    // Check is user directory exists
    let user_dir_path = audio_dir_path.join(&user_id);
    if !user_dir_path.exists() {
        // CREATE DIRECTORY
        let _ = create_dir_all(&user_dir_path);
    }
    let now = Utc::now().timestamp();
    // UCG formated filename
    let filename = format!("{}-{}-{}-{}.wav", mode, audio_id, user_id, now);
    let userfilepath = user_dir_path.join(filename);
    match userfilepath.to_str() {
        Some(userfile) => Ok(userfile.to_string()),
        None => Err(anyhow::Error::msg("failed to get audio directory")),
    }
}
