/* eslint-disable no-script-url */
/* eslint-disable jsx-a11y/anchor-is-valid */
import axios from 'axios';
import { CSSProperties } from 'react';
import { Component } from 'react';
import { Col, Row, Spinner } from 'react-bootstrap';
import YouTube, { Options } from 'react-youtube';
import { GiMicrophone, GiDrumKit, GiGuitarHead, GiGuitarBassHead, GiPianoKeys, GiPlayButton, GiPauseButton } from 'react-icons/gi';
import { IconContext } from 'react-icons';
import { db, AudioFiles } from '../../lib/db';
import { FormattedMessage } from 'react-intl';
import { Channel, Player } from 'tone';
import ActionCable from 'actioncable';
import { Result } from './models/Result';
import { AudioFile, Status } from './models/AudioFile';
import { YouTubeEventTarget } from './models/YouTubeEventTarget';
import { YouTubePlayerState } from './models/YouTubePlayerState';
import { Mode } from './models/Mode';
import { LoadingView } from '../templates/LoadingView';

const buttonStyle: CSSProperties = {

}

type AudioProps = {
    audioId: string
}

type AudioState = {
    errorMessage: string
    audioFile: AudioFile | null
    playerTime: number
    isPlayerReady: boolean
    isYoutubePlayerReady: boolean
    isPlaying: boolean
    vocalAudioOn: boolean
    guitarAudioOn: boolean
    bassAudioOn: boolean
    drumsAudioOn: boolean
    pianoAudioOn: boolean
}

const actionCableHost = process.env.REACT_APP_ACTION_CABLE_URL || 'ws://localhost:3000/cable'

class AudioPlayer extends Component<AudioProps, AudioState> {

    vocalPlayer: Player | null = null;
    otherPlayer: Player | null = null;
    bassPlayer: Player | null = null;
    drumsPlayer: Player | null = null;
    pianoPlayer: Player | null = null;

    youTubeEventTarget: YouTubeEventTarget | null = null
    updateYouTubePlayerStatusIntervalId: any | null = null

    debugChannel: any
    cableApp = ActionCable.createConsumer(actionCableHost)

    constructor(props: AudioProps) {
        super(props);
        this.state = {
            errorMessage: '',
            audioFile: null,
            playerTime: 0,
            isPlayerReady: false,
            isYoutubePlayerReady: false,
            isPlaying: false,
            vocalAudioOn: true,
            guitarAudioOn: true,
            bassAudioOn: true,
            drumsAudioOn: true,
            pianoAudioOn: true,
        }

        const received = (data: AudioFile) => {
            this._updateProgress(data)
        }

        const conected = () => { }

        this.debugChannel = this.cableApp.subscriptions.create({
            channel: 'FileProcessingChannel',
            audioFileId: this.state.audioFile?.id
        }, {
            conected,
            received
        })
    }

    componentDidMount() {
        const audioFileId = this.props.audioId;
        axios.get(`/splitfire/${audioFileId}`)
            .then(res => {
                // console.log("Get results", res);
                const audioFile = res.data.audio_file;
                this.setState({ audioFile });
                // console.log(this.state);
                this._downloadAudioFilesIfNeeded();
            })
            .catch(error => {
                //console.log(error)
                this.setState({ errorMessage: 'Something error with this file.' })
            });
    }

    componentWillUnmount() {
        this.setState({ isPlaying: false })
        this.vocalPlayer?.stop()
        this.bassPlayer?.stop()
        this.drumsPlayer?.stop()
        this.pianoPlayer?.stop()
        this.otherPlayer?.stop()

        this.cableApp.disconnect()
    }

    _updateProgress(data: AudioFile) {
        //console.log(data)

        this.setState({ audioFile: data })

        if (this.state.audioFile?.status === Status.DONE)
            window.location.reload();
    }

    _downloadAudioFilesIfNeeded() {

        if (this.state.audioFile?.status !== Status.DONE)
            return

        this._prepareAudio(Mode.Vocal);
        this._prepareAudio(Mode.Bass);
        this._prepareAudio(Mode.Drum);
        this._prepareAudio(Mode.Guitar);
        this._prepareAudio(Mode.Keyboard);
    }

    async _downloadFile(type: Mode) {
        // //console.log('_downloadFile', type);
        let audioFile: Result | undefined;
        switch (type) {
            case Mode.Vocal:
                audioFile = this.state.audioFile?.results.find(obj => { return obj.filename.startsWith('vocals') });
                break;
            case Mode.Bass:
                audioFile = this.state.audioFile?.results.find(obj => { return obj.filename.startsWith('bass') });
                break;
            case Mode.Drum:
                audioFile = this.state.audioFile?.results.find(obj => { return obj.filename.startsWith('drums') });
                break;
            case Mode.Guitar:
                audioFile = this.state.audioFile?.results.find(obj => { return obj.filename.startsWith('other') });
                break;
            case Mode.Keyboard:
                audioFile = this.state.audioFile?.results.find(obj => { return obj.filename.startsWith('piano') });
                break;
        }

        const audioFileId = this.props.audioId;
        // console.log("Download url", audioFile?.source_file);
        axios({
            url: audioFile?.source_file,
            method: 'GET',
            responseType: 'blob',
        }).then((response) => {
            const file = new Blob([response.data], { type: 'audio/mp3' });
            const item: AudioFiles = {
                audioFileId, type: type, file
            }
            db.audioFiles.add(item);
            // console.log('File Downloaded', file);
            this._setAudioSrc(type, file);
        }).catch(error => {
            // console.log(error);
        });
    }

    async _prepareAudio(type: Mode) {
        const audioFileId = this.props.audioId;
        db.audioFiles
            .get({ audioFileId: audioFileId, type: type })
            .then((record: AudioFiles | undefined) => {
                if (record?.file === undefined) {
                    this._downloadFile(type);
                    return
                }
                this._setAudioSrc(type, record.file)
            })
            .catch((onrejected: any) => {
                // console.log("Rejected", onrejected);
            });
    }

    _setAudioSrc(type: Mode, file: Blob) {
        // Get window.URL object
        const URL = window.URL || window.webkitURL;
        // Create and revoke ObjectURL
        const audioFileURL = URL.createObjectURL(file);
        const channel = new Channel().toDestination();

        switch (type) {
            case Mode.Vocal:
                this.vocalPlayer = new Player({ url: audioFileURL, onload: this._updatePlayerStatus })
                this.vocalPlayer.connect(channel);
                break;
            case Mode.Bass:
                this.bassPlayer = new Player({ url: audioFileURL, onload: this._updatePlayerStatus })
                this.bassPlayer.connect(channel);
                break;
            case Mode.Drum:
                this.drumsPlayer = new Player({ url: audioFileURL, onload: this._updatePlayerStatus })
                this.drumsPlayer.connect(channel);
                break;
            case Mode.Guitar:
                this.otherPlayer = new Player({ url: audioFileURL, onload: this._updatePlayerStatus })
                this.otherPlayer.connect(channel);
                break;
            case Mode.Keyboard:
                this.pianoPlayer = new Player({ url: audioFileURL, onload: this._updatePlayerStatus })
                this.pianoPlayer.connect(channel);
                break;
        }
    }

    _updatePlayerStatus: (() => void) = () => {
        if (
            this.vocalPlayer?.loaded &&
            this.drumsPlayer?.loaded &&
            this.otherPlayer?.loaded &&
            this.bassPlayer?.loaded &&
            this.pianoPlayer?.loaded
        ) {
            this.setState({ isPlayerReady: true });
        }
    }

    togglePlayAudio() {
        this.setState({ isPlaying: !this.state.isPlaying })
        if (this.state.isPlaying) {
            this.vocalPlayer?.stop()
            this.bassPlayer?.stop()
            this.drumsPlayer?.stop()
            this.pianoPlayer?.stop()
            this.otherPlayer?.stop()
            this.youTubeEventTarget?.pauseVideo()
        } else {
            this.youTubeEventTarget?.seekTo(0)
            this.youTubeEventTarget?.playVideo()
            this.vocalPlayer?.start();
            this.bassPlayer?.start();
            this.drumsPlayer?.start();
            this.pianoPlayer?.start();
            this.otherPlayer?.start();
        }
    }

    setToggleInstrument(mode: Mode) {
        switch (mode) {
            case Mode.Vocal:
                if (!this.vocalPlayer) return;
                this.setState({ vocalAudioOn: !this.state.vocalAudioOn });
                this.vocalPlayer.mute = this.state.vocalAudioOn;
                break;
            case Mode.Bass:
                if (!this.bassPlayer) return;
                this.setState({ bassAudioOn: !this.state.bassAudioOn });
                this.bassPlayer.mute = this.state.bassAudioOn;
                break;
            case Mode.Guitar:
                if (!this.otherPlayer) return;
                this.setState({ guitarAudioOn: !this.state.guitarAudioOn });
                this.otherPlayer.mute = this.state.guitarAudioOn;
                break;
            case Mode.Keyboard:
                if (!this.pianoPlayer) return;
                this.setState({ pianoAudioOn: !this.state.pianoAudioOn });
                this.pianoPlayer.mute = this.state.pianoAudioOn;;
                break;
            case Mode.Drum:
                if (!this.drumsPlayer) return;
                this.setState({ drumsAudioOn: !this.state.drumsAudioOn });
                this.drumsPlayer.mute = this.state.drumsAudioOn;
                break;
        }
    }

    render() {

        const { audioFile, errorMessage, isPlayerReady, isYoutubePlayerReady, isPlaying } = this.state

        if (errorMessage.length > 0) {
            return (
                <p>Something wrong with this file.</p>
            )
        }

        if (audioFile?.status === Status.DOWNLOADING || audioFile?.status === Status.SPLITTING) {
            return <p>Processing file: {audioFile.progress}% </p>
        }

        if (isPlayerReady) {
            const opts: Options = {
                width: '100%',
                playerVars: {
                    // https://developers.google.com/youtube/player_parameters
                    autoplay: 0,
                    mute: 1,
                    controls: 0,
                    rel: 0,
                    showinfo: 0
                },
            };
            let togglePlayButton = <div>
                <p>
                    <FormattedMessage id="player.loadingYoutube"
                        defaultMessage="Generating video..."
                        description="Loading message" />
                </p>
                <Spinner animation='grow' variant="danger"></Spinner>
            </div>
            if (isYoutubePlayerReady) {
                let button
                if (isPlaying) {
                    button = <Col>
                        <GiPauseButton
                            color={isPlaying ? `white` : `red`}
                            onClick={() => this.togglePlayAudio()}
                            style={buttonStyle} />
                    </Col>
                } else {
                    button = <Col>
                        <GiPlayButton
                            color={isPlaying ? `white` : `red`}
                            onClick={() => this.togglePlayAudio()}
                            style={buttonStyle} />
                    </Col>
                }
                togglePlayButton = <Col>
                    <p>
                        <FormattedMessage id="player.instruction"
                            defaultMessage="Click isntrument icon to mute part of the song."
                            description="Instruction message" />
                    </p>
                    {button}
                </Col>
            }

            return (
                <IconContext.Provider value={{ size: "2em", color: "white", className: "global-class-name" }}>
                    <Row className="mb-3 mt-3">
                        <Col>
                            <h1>{this.state.audioFile?.name}</h1>
                        </Col>
                    </Row>
                    <Row className="mb-3 mt-3">
                        {togglePlayButton}
                    </Row>
                    <Row className="mb-3 mt-3">
                        <Col>
                            <GiMicrophone
                                color={this.state.vocalAudioOn ? `white` : `red`}
                                onClick={() => this.setToggleInstrument(Mode.Vocal)}
                                style={buttonStyle} />
                        </Col>
                        <Col>
                            <GiDrumKit
                                color={this.state.drumsAudioOn ? `white` : `red`}
                                onClick={() => this.setToggleInstrument(Mode.Drum)}
                                style={buttonStyle} />
                        </Col>
                        <Col>
                            <GiGuitarBassHead
                                color={this.state.bassAudioOn ? `white` : `red`}
                                onClick={() => this.setToggleInstrument(Mode.Bass)}
                                style={buttonStyle} />
                        </Col>
                        <Col>
                            <GiGuitarHead
                                color={this.state.guitarAudioOn ? `white` : `red`}
                                onClick={() => this.setToggleInstrument(Mode.Guitar)}
                                style={buttonStyle} />
                        </Col>
                        <Col>
                            <GiPianoKeys
                                color={this.state.pianoAudioOn ? `white` : `red`}
                                onClick={() => this.setToggleInstrument(Mode.Keyboard)}
                                style={buttonStyle} />
                        </Col>
                    </Row>
                    <Row>
                        <Col style={{ display: isYoutubePlayerReady ? 'block' : 'none', pointerEvents: 'none' }}>
                            <YouTube
                                videoId={this.state.audioFile?.youtube_video_id}
                                opts={opts}
                                onReady={this._onReady.bind(this)}
                                onStateChange={this._onStateChange.bind(this)}
                            />
                        </Col>
                    </Row>
                </IconContext.Provider>
            )
        } else {
            return <LoadingView />
        }
    }

    _onReady(event: any) {
        this.youTubeEventTarget = event.target
        this.youTubeEventTarget?.playVideo()
        this.updateYouTubePlayerStatusIntervalId = setInterval(() => {
            if (!this.state.isYoutubePlayerReady) {
                this._updateYouTubePlayerStatusIfNeeded()
            }
        }, 2000)
    }

    _onStateChange(event: any) {
        if (!this.youTubeEventTarget) return

        if (this.youTubeEventTarget.getPlayerState() === YouTubePlayerState.ended) {
            this.setState({ isPlaying: false })
        }
    }

    _updateYouTubePlayerStatusIfNeeded() {

        if (this.state.isYoutubePlayerReady) return
        if (!this.youTubeEventTarget) return

        // Let's say 5 seconds buffer is enough.
        if (this.youTubeEventTarget?.getCurrentTime() > 5) {
            this.setState({ isYoutubePlayerReady: true })
            this.youTubeEventTarget?.pauseVideo()

            if (this.updateYouTubePlayerStatusIntervalId)
                clearInterval(this.updateYouTubePlayerStatusIntervalId)
        }
    }

}

export default AudioPlayer;