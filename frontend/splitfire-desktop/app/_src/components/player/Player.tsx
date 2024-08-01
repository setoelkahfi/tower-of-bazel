import { useCallback, useContext, useEffect, useState } from "react"
import { Col, Container, Row } from "react-bootstrap"
import { useParams } from "react-router-dom"
import { ModeDemucs } from "./models/Mode"
import { useLogger } from "../../lib/logger"
import { CountDownView } from "./CountDownView"
import ErrorView from "../templates/Error"
import { LoadingView } from "../templates/LoadingView"
import { invoke } from '@tauri-apps/api'
import { UserContext } from "../../lib/CurrentUserContext"
import { TAURI_PLAYER_RECORD, TAURI_PLAYER_SET_VOLUME, TAURI_PLAYER_PAUSED, TAURI_PLAYER_UNMOUNT, TAURI_PLAYER_PREPARE, TAURI_PLAYER_STOP, TAURI_PLAYER_RESUMED, TAURI_PLAYER_PLAY, TAURI_PLAYER_RECORDING_LENGTH, TAURI_PLAYER_RECORD_STOP } from "../../lib/tauriHandler"
import { ControlButtonsView } from "./ControlButtons"
import { VolumeSliderView } from "./VolumeSliderView"
import { HideShowToggleView } from "./HideShowToggle"
import { RecordingView } from "./RecordingView"
import { PlayerPrepareResponse } from "@/models/content"
import { TauriResponse } from "@/models/shared"

enum State {
    LOADING,
    LOADED,
    ERROR,
}

enum PlayerState {
    STOPPED,
    PLAYING,
    PAUSED,
    RECORDING
}

interface PlayerVolume {
    mode: ModeDemucs,
    volume: string
}

export function PlayerAudio() {

    const log = useLogger('PlayerAudio')
    const { providerId } = useParams()
    const { user } = useContext(UserContext)

    const [state, setState] = useState(State.LOADING)
    const [title, setTitle] = useState<string>('Loading audio ...')
    const [isCountingCountdown, setIsCountingCountdown] = useState(false)
    const [recordingLength, setRecordingLength] = useState<number>(0)
    const [hideVolumeSliders, setHideVolumeSliders] = useState(false)
    const [playerState, setPlayerState] = useState<PlayerState>(PlayerState.STOPPED)

    // Volumes 
    const [vocalsVolume, setVocalsVolume] = useState<string>('100')
    const [drumsVolume, setDrumsVolume] = useState<string>('100')
    const [bassVolume, setBassVolume] = useState<string>('100')
    const [otherVolume, setOtherVolume] = useState<string>('100')

    const COUNTING_DOWN_NUMBER = 3

    const _onVolumeChange = (mode: ModeDemucs, value: string) => {
        log.debug('_onVolumeChange', mode, value)
        switch (mode) {
            case ModeDemucs.Vocals:
                setVocalsVolume(value)
                break;
            case ModeDemucs.Drums:
                setDrumsVolume(value)
                break;
            case ModeDemucs.Bass:
                setBassVolume(value)
                break;
            case ModeDemucs.Other:
                setOtherVolume(value)
                break;
        }
        invoke(TAURI_PLAYER_SET_VOLUME, { mode: mode, volume: value })
    }

    const _playerVolumes = (): PlayerVolume[] => {
        return [
            { mode: ModeDemucs.Vocals, volume: vocalsVolume },
            { mode: ModeDemucs.Drums, volume: drumsVolume },
            { mode: ModeDemucs.Bass, volume: bassVolume },
            { mode: ModeDemucs.Other, volume: otherVolume },
        ]
    }

    const _toggleRecording = async () => {
        try {
            // If we are playing playbacks, stop it before recording.
            if (playerState === PlayerState.PLAYING) {
                setPlayerState(PlayerState.STOPPED)
                const result = await invoke(TAURI_PLAYER_STOP, { audioId: providerId, userId: user?.user.id })
                log.debug(TAURI_PLAYER_STOP, result)
            }

            // If we're already recording, we want to stop it and return.
            if (playerState === PlayerState.RECORDING) {
                _stopRecording()
                return
            }

            // Otherwise, we're good to go.
            // Get the length of the audio file.

            let length: number = await invoke(TAURI_PLAYER_RECORDING_LENGTH, { audioId: providerId, userId: user?.user.id })
            log.debug(TAURI_PLAYER_RECORDING_LENGTH, length)
            setRecordingLength(length)
            setIsCountingCountdown(true)

            setTimeout(async () => {
                log.debug(TAURI_PLAYER_RECORD, 'Start recording')
                setPlayerState(PlayerState.RECORDING)
                setIsCountingCountdown(false)
                const result = await invoke(TAURI_PLAYER_RECORD, { audioId: providerId, userId: user?.user.id, playerVolumes: _playerVolumes() })
                log.debug(TAURI_PLAYER_RECORD, result)
            }, COUNTING_DOWN_NUMBER * 1000)
        } catch (error) {
            log.error(error)
        }
    }

    const _stopRecording = async () => {
        setRecordingLength(0)
        setPlayerState(PlayerState.STOPPED)
        const stop_recording_result = await invoke(TAURI_PLAYER_RECORD_STOP, { audioId: providerId, userId: user?.user.id })
        const result = await invoke(TAURI_PLAYER_STOP, { audioId: providerId, userId: user?.user.id })
        log.debug(TAURI_PLAYER_STOP, result)
        log.debug(TAURI_PLAYER_RECORD_STOP, stop_recording_result)
    }

    const _stopPlayer = async () => {
        try {
            setPlayerState(PlayerState.STOPPED)
            setRecordingLength(0)
            const result = await invoke(TAURI_PLAYER_STOP, { audioId: providerId, userId: user?.user.id })
            log.debug(TAURI_PLAYER_STOP, result)
        } catch (error) {
            log.error(error)
        }
    }

    const _togglePlayAudio = async () => {
        // Should disabled when recording
        if (playerState === PlayerState.RECORDING) {
            return
        }
        try {
            switch (playerState) {
                case PlayerState.STOPPED:
                    log.debug(TAURI_PLAYER_PLAY, 'Start playing')
                    setIsCountingCountdown(true)
                    setTimeout(async () => {
                        setIsCountingCountdown(false)
                        setPlayerState(PlayerState.PLAYING)
                        await invoke(TAURI_PLAYER_PLAY, { playerVolumes: _playerVolumes() })
                    }, COUNTING_DOWN_NUMBER * 1000)
                    break;
                case PlayerState.PLAYING:
                    log.debug(TAURI_PLAYER_PAUSED, 'Paused')
                    setPlayerState(PlayerState.PAUSED)
                    await invoke(TAURI_PLAYER_PAUSED)
                    break;
                case PlayerState.PAUSED:
                    log.debug(TAURI_PLAYER_RESUMED, 'Resumed')
                    setPlayerState(PlayerState.PLAYING)
                    await invoke(TAURI_PLAYER_PLAY, { playerVolumes: _playerVolumes() })
            }
        } catch (error) {
            log.error(error)
        }
    }

    const preparePlayer = useCallback(async () => {
        if (!providerId) {
            log.error('providerId is null')
            setState(State.ERROR)
            return
        }
        log.debug('preparePlayer', providerId)
        try {
            const result: PlayerPrepareResponse = await invoke(TAURI_PLAYER_PREPARE, { providerId: providerId })
            log.debug('PreparePlayerResponse', result)
            switch (result.status) {
                case TauriResponse.SUCCESS:
                    if (result.audio_file_name)
                        setTitle(result.audio_file_name)

                    setState(State.LOADED)
                    break;
                case TauriResponse.ERROR:
                    setState(State.ERROR)
                    break;
            }
        } catch (error) {
            log.error(error)
            setState(State.ERROR)
        }
    }, [])

    const onFinishedRecording = () => {
        log.debug('Recording finished')
        //_toggleRecording()
    }

    const _willUnmount = () => {
        try {
            const result = invoke(TAURI_PLAYER_UNMOUNT, { audioId: providerId, userId: user?.user.id })
            log.debug(TAURI_PLAYER_UNMOUNT, result)
        }
        catch (error) {
            log.error(error)
        }
    }

    useEffect(() => {
        preparePlayer()

        return () => {
            _willUnmount()
        }
    }, [])

    if (state === State.LOADING) {
        return <LoadingView />
    }

    if (state === State.ERROR) {
        return <ErrorView errorMessage="Something went wrong ..." />
    }

    let buttonOrCounting = <></>
    if (isCountingCountdown) {
        buttonOrCounting = <CountDownView seconds={COUNTING_DOWN_NUMBER} type="" />
    } else {
        buttonOrCounting = <ControlButtonsView
            isPlaying={playerState === PlayerState.PLAYING}
            isRecording={playerState === PlayerState.RECORDING}
            onClick={_togglePlayAudio}
            onStop={_stopPlayer}
            onRecord={_toggleRecording}
        />
    }

    let audioWaveform = <></>
    if (playerState === PlayerState.PLAYING || playerState === PlayerState.PAUSED) {
        audioWaveform = <>
            <CountDownView seconds={recordingLength} type="Practicing!!!" />
        </>
    } else if (playerState === PlayerState.RECORDING) {
        audioWaveform = <RecordingView length={recordingLength} onRecordingEnd={onFinishedRecording} />
    }

    return <Container>
        <Row>
            <Col xs={12} className="mb-3 mt-3">
                <h1>{title}</h1>
            </Col>
        </Row>
        {buttonOrCounting}
        <Row className="h-100 d-inline-block">
            <Col xs={12} className="mb-3 mt-3">
                <Container style={{ height: 300 }}>
                    <div className="d-flex align-items-center justify-content-center h-100">
                        <div className="d-flex flex-column">
                            {audioWaveform}
                        </div>
                    </div>
                </Container>
            </Col>
        </Row>
        <Row className="border border-light">
            <Col xs={2} className="mb-3 mt-3">
                <p color="red">Volume</p>
            </Col>
            <Col xs={{ span: 2, offset: 8 }} className="mb-3 mt-3">
                <HideShowToggleView hideVolumeSliders={hideVolumeSliders} setHideVolumeSliders={setHideVolumeSliders} />
            </Col>
            <VolumeSliderView _onVolumeChange={_onVolumeChange} isHidden={hideVolumeSliders} />
        </Row>
    </Container>
}