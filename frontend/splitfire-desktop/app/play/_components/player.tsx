"use client";

import {
  TAURI_PLAYER_PAUSED,
  TAURI_PLAYER_PLAY,
  TAURI_PLAYER_RECORD,
  TAURI_PLAYER_RECORD_STOP,
  TAURI_PLAYER_RECORDING_LENGTH,
  TAURI_PLAYER_RESUMED,
  TAURI_PLAYER_SET_VOLUME,
  TAURI_PLAYER_STOP,
} from "@/lib/tauri-handler";
import { invoke } from "@tauri-apps/api/tauri";
import { useState } from "react";
import { ControlButtons } from "./control-button";
import { AudioInfo } from "./audio-info";
import { AudioInfoMiddle } from "./audio-info-middle";
import { useLogger } from "@/lib/logger";
import { ModeDemucs } from "@/models/mode";

enum PlayerState {
  STOPPED,
  PLAYING,
  PAUSED,
  RECORDING
}

export interface PlayerVolume {
  mode: ModeDemucs,
  volume: string
}


export default function Player({
  audioId,
  userId,
}: {
  audioId: string;
  userId: number;
}) {
  // Logger
  const log = useLogger("Player");

  // State and constants
  const COUNTING_DOWN_NUMBER = 3;
  const [isCountingCountdown, setIsCountingCountdown] = useState(false);
  const [recordingLength, setRecordingLength] = useState<number>(0);
  const [hideVolumeSliders, setHideVolumeSliders] = useState(false);
  const [playerState, setPlayerState] = useState<PlayerState>(
    PlayerState.STOPPED
  );

  // Player states
  const [vocalsVolume, setVocalsVolume] = useState<string>("100");
  const [drumsVolume, setDrumsVolume] = useState<string>("100");
  const [bassVolume, setBassVolume] = useState<string>("100");
  const [otherVolume, setOtherVolume] = useState<string>("100");

  // Player functions
  const onVolumeChange = (mode: ModeDemucs, value: string) => {
    log.debug("onVolumeChange", mode, value);
    switch (mode) {
      case ModeDemucs.Vocals:
        setVocalsVolume(value);
        break;
      case ModeDemucs.Drums:
        setDrumsVolume(value);
        break;
      case ModeDemucs.Bass:
        setBassVolume(value);
        break;
      case ModeDemucs.Other:
        setOtherVolume(value);
        break;
    }
    invoke(TAURI_PLAYER_SET_VOLUME, { mode: mode, volume: value });
  };

  const onFinishedRecording = () => {
    log.debug("Recording finished");
    //_toggleRecording()
  };

  const toggleRecording = async () => {
    try {
      // If we are playing playbacks, stop it before recording.
      if (playerState === PlayerState.PLAYING) {
        setPlayerState(PlayerState.STOPPED);
        const result = await invoke(TAURI_PLAYER_STOP, {
          audioId,
          userId,
        });
        log.debug(TAURI_PLAYER_STOP, result);
      }

      // If we're already recording, we want to stop it and return.
      if (playerState === PlayerState.RECORDING) {
        stopRecording();
        return;
      }

      // Otherwise, we're good to go.
      // Get the length of the audio file.

      let length: number = await invoke(TAURI_PLAYER_RECORDING_LENGTH, {
        audioId,
        userId,
      });
      log.debug(TAURI_PLAYER_RECORDING_LENGTH, length);
      setRecordingLength(length);
      setIsCountingCountdown(true);

      setTimeout(async () => {
        log.debug(TAURI_PLAYER_RECORD, "Start recording");
        setPlayerState(PlayerState.RECORDING);
        setIsCountingCountdown(false);
        const result = await invoke(TAURI_PLAYER_RECORD, {
          audioId,
          userId,
          playerVolumes: currentPlayerVolumes(),
        });
        log.debug(TAURI_PLAYER_RECORD, result);
      }, COUNTING_DOWN_NUMBER * 1000);
    } catch (error) {
      log.error(error);
    }
  };

  const stopRecording = async () => {
    setRecordingLength(0);
    setPlayerState(PlayerState.STOPPED);
    const stop_recording_result = await invoke(TAURI_PLAYER_RECORD_STOP, {
      audioId,
      userId,
    });
    const result = await invoke(TAURI_PLAYER_STOP, {
      audioId,
      userId,
    });
    log.debug(TAURI_PLAYER_STOP, result);
    log.debug(TAURI_PLAYER_RECORD_STOP, stop_recording_result);
  };

  const _stopPlayer = async () => {
    try {
      setPlayerState(PlayerState.STOPPED);
      setRecordingLength(0);
      const result = await invoke(TAURI_PLAYER_STOP, {
        audioId,
        userId,
      });
      log.debug(TAURI_PLAYER_STOP, result);
    } catch (error) {
      log.error(error);
    }
  };
  const currentPlayerVolumes = (): PlayerVolume[] => {
    return [
      { mode: ModeDemucs.Vocals, volume: vocalsVolume },
      { mode: ModeDemucs.Drums, volume: drumsVolume },
      { mode: ModeDemucs.Bass, volume: bassVolume },
      { mode: ModeDemucs.Other, volume: otherVolume },
    ];
  };

  const togglePlayAudio = async () => {
    // Should disabled when recording
    if (playerState === PlayerState.RECORDING) {
      return;
    }
    try {
      switch (playerState) {
        case PlayerState.STOPPED:
          log.debug(TAURI_PLAYER_PLAY, "Start playing");
          setIsCountingCountdown(true);
          setTimeout(async () => {
            setIsCountingCountdown(false);
            setPlayerState(PlayerState.PLAYING);
            await invoke(TAURI_PLAYER_PLAY, {
              playerVolumes: currentPlayerVolumes(),
            });
          }, COUNTING_DOWN_NUMBER * 1000);
          break;
        case PlayerState.PLAYING:
          log.debug(TAURI_PLAYER_PAUSED, "Paused");
          setPlayerState(PlayerState.PAUSED);
          await invoke(TAURI_PLAYER_PAUSED);
          break;
        case PlayerState.PAUSED:
          log.debug(TAURI_PLAYER_RESUMED, "Resumed");
          setPlayerState(PlayerState.PLAYING);
          await invoke(TAURI_PLAYER_PLAY, { playerVolumes: currentPlayerVolumes() });
      }
    } catch (error) {
      log.error(error);
    }
  };
  
  return (
    <>
      <div className="bg-black border-slate-100 dark:bg-slate-800 dark:border-slate-500 border-b rounded-t-xl p-4 pb-6 sm:p-10 sm:pb-8 lg:p-6 xl:p-10 xl:pb-8 space-y-6 sm:space-y-8 lg:space-y-6 xl:space-y-8  items-center">
        <AudioInfo />
        <AudioInfoMiddle counterDownTimer={COUNTING_DOWN_NUMBER} />
        <ControlButtons
          isPlaying={playerState === PlayerState.PLAYING}
          isRecording={playerState === PlayerState.RECORDING}
          onClick={togglePlayAudio}
          onStop={_stopPlayer}
          onRecord={toggleRecording} 
          onResume={function (): void {
            throw new Error("Function not implemented.");
          } } />
      </div>
    </>
  );
}
