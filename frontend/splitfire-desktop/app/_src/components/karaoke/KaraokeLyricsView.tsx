import axios from "axios";
import { Component } from "react";
import { Alert, Button, Col, Container, Row } from "react-bootstrap";
import { BsPlusCircle } from "react-icons/bs";
import { Navigate, useParams } from "react-router-dom";
import { CurrentUser } from "../../lib/db";
import LyricSynch, { compare } from "../../models/lyricSynches";
import { useCurrentUser } from "./KaraokeView";
import LyricSynchRow from "./LyricSynchRow";

export default function KaraokeLyricsView() {
    const { audioFileId } = useParams()
    const { currentUser } = useCurrentUser()

    if (!audioFileId) {
        return <p>Something wrong...</p>
    }
    return <KaraokeLyrics audioFileId={audioFileId} currentUser={currentUser} />
}

interface KaraokeLyricsProps {
    audioFileId: string
    currentUser: CurrentUser
}

interface KaraokeLyricsState {
    lyrics: LyricSynch[]
    errorMessage: string
    processing: boolean
    validationMessage: string
    shouldNavigateToPlayer: boolean
}

export class KaraokeLyrics extends Component<KaraokeLyricsProps, KaraokeLyricsState> {

    constructor(props: KaraokeLyricsProps) {
        super(props)
        this.state = {
            lyrics: [],
            errorMessage: '',
            processing: false,
            validationMessage: '',
            shouldNavigateToPlayer: false
        }
    }

    componentDidMount() {
        axios
            .get(`/lyric_synches/${this.props.audioFileId}`, {
                headers: {
                    'Authorization': this.props.currentUser.accessToken
                }
            })
            .then(res => {
                const lyricSynches: LyricSynch[] = res.data.lyric_synches
                //console.log(lyricSynches)
                this.setState({
                    lyrics: lyricSynches
                })
            })
            .catch(error => {
                //console.log(error)
                this.setState({ errorMessage: 'Something error with this file.' })
            });
    }
 
    addLine() {
        const { lyrics } = this.state
        lyrics.push({ id: -1, lyric: '', time: '00:00' })
        this.setState({ lyrics })
        ////console.log(this.state)
    }

    removeLine(index: number) {
        const { lyrics } = this.state
        delete lyrics[index]
        this.setState({ lyrics })
        //console.log(this.state)
    }

    updateTime(index: number, time: string) {
        const { lyrics } = this.state
        lyrics[index].time = time
        this.setState({ lyrics })
        //console.log('updateTime', this.state)
    }

    updateLyric(index: number, lyric: string) {
        const { lyrics } = this.state
        lyrics[index].lyric = lyric
        this.setState({ lyrics })
        //console.log('updateLyric', this.state)
    }

    submit() {
        //console.log(this.state)
        this.setState({ processing: true })
        const isEmpty = (element: LyricSynch) => element.lyric.length === 0
        if (this.state.lyrics.some(isEmpty)) {
            this.setState({
                processing: false,
                validationMessage: 'Lyrics cannot be empty.'
            })
            return
        }
        const isNewLyric = (element: LyricSynch) => element.id < 0
        const isExistingLyric = (element: LyricSynch) => element.id > 0
        const newLyrics = this.state.lyrics.filter(isNewLyric)
        const existingLyrics = this.state.lyrics.filter(isExistingLyric)

        let requests = []
        // Find lyrics to update
        if (existingLyrics.length > 0) {
            requests.push(
                axios
                    .put(`/lyric_synches/${this.props.audioFileId}`, {
                            payload: existingLyrics
                        }, {
                            headers: {
                                'Authorization': this.props.currentUser.accessToken
                            }
                    })
            )
        }

        // Find lyrics to add
        if (newLyrics.length > 0) {
            requests.push(
                axios
                    .post(`/lyric_synches/${this.props.audioFileId}`, {
                        payload: newLyrics
                    }, {
                        headers: {
                            'Authorization': this.props.currentUser.accessToken
                        }
                    })
            )
        }

        axios
            .all(requests)
            .then(axios.spread((data1, data2) => {
                // output of req.
                //console.log('data1', data1, 'data2', data2)
                if ((data1 && data1.data.code === 200) || (data2 && data2.data.code === 200)) {
                    this.setState({ shouldNavigateToPlayer: true })
                } else {
                    this.setState({
                        processing: false,
                        validationMessage: 'Request error.'
                    })
                }
            }))
            .catch(error => {
                //console.log(error)
                this.setState({
                    processing: false,
                    validationMessage: 'Request error.'
                })
            })
    }

    buttonTitle(): string {
        return this.state.processing ? 'Processing...' : 'Submit'
    }

    render() {

        const { lyrics, processing, errorMessage, validationMessage, shouldNavigateToPlayer } = this.state

        if (shouldNavigateToPlayer) {
            return <Navigate to={`/karaoke/${this.props.audioFileId}`} />
        }

        if (errorMessage.length > 0) {
            return <p>Cannot load file.</p>
        }

        let validationMessageView
        if (validationMessage.length > 0) {
            validationMessageView =  <Alert variant="danger" onClose={() => this.setState({ validationMessage: ''})} dismissible><p>{validationMessage}</p></Alert>
        }

        return <Container>
            {validationMessageView}
            <Row>
                <Col>
                {lyrics.sort(compare).map((lyric, index) => (
                    <LyricSynchRow
                        lyricSynch={lyric}
                        key={index}
                        index={index}
                        onRemove={ () => { this.removeLine(index) }} 
                        onTimeChange={ (time: string) => { this.updateTime(index, time) } }
                        onLyricChange={ (lyric: string) => { this.updateLyric(index, lyric) } } 
                        processing={processing}
                        />
                ))}
                </Col>
            </Row>
            <Row className="mb-4">
                <Col>
                    <Button onClick={() => this.addLine()} >
                        <BsPlusCircle color={`white`} />
                    </Button>
                </Col>
            </Row>
            <Row>
                <Col>
                    <Button 
                        variant="primary"
                        onClick={() => this.submit() }
                        disabled={processing} >
                        {this.buttonTitle()}
                    </Button>
                </Col>
            </Row>
        </Container>
    }
}