import { IntlProvider } from 'react-intl'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import 'bootstrap/dist/css/bootstrap.min.css'
import messagesEn from './translations/en.json'
//import messagesId from './translations/id.json'
import './App.css';
import Main from './components/templates/Main';
import axios from 'axios'
import About from './components/pages/About'
import Home from './components/pages/Home'
import Login from './components/profiles/Login'
import Logout from './components/profiles/Logout'
import { ProfileRootView } from './components/profiles/Profile'
import { ProfileFollowersRootView } from './components/profiles/ProfileFollowers'
import { ProfileFollowingRootView } from './components/profiles/ProfileFollowing'
import Song from './components/player/Song'
import { CurrentUser, CurrentUserType, db } from './lib/db'
import { ProfileNetworksRootView } from './components/profiles/ProfileNetworks'
import Contact from './components/pages/Contact'
import KaraokeView from './components/karaoke/KaraokeView'
import { KaraokePlayerView } from './components/karaoke/KaraokePlayerView'
import KaraokeLyricsView from './components/karaoke/KaraokeLyricsView'
import Search from './components/pages/Search';
import { SongView as SongDetailView } from './components/pages/song/SongView';
import { Split } from './components/pages/esef/Split';
import { SplitDetailView } from './components/pages/esef/SplitFireView';
import { useEffect, useState } from 'react';
import { Container, Spinner } from 'react-bootstrap';
import { UserContext } from './lib/CurrentUserContext';
import { PlayerAudio } from './components/player/Player';
import { PlayerView } from './components/player/PlayerView';
import { useLogger } from '../../lib/logger';
import { LoadingView } from './components/templates/LoadingView';

let i18nConfig = {
  language: 'en',
  messages: messagesEn
};

let host = process.env.REACT_APP_SPLITFIRE_API_HOST;

axios.defaults.baseURL = `https://${host}/api/v1/`

enum State {
  LOADING,
  LOADED,
  ERROR
}

export default function App() {

  const log = useLogger('App')
  const [state, setState] = useState(State.LOADING)
  const [user, setUser] = useState<CurrentUser | null>(null)

  const getCurrentUser = async () => {
    setState(State.LOADING)
    try {
      const result = await db.currentUser.where({ type: CurrentUserType.MAIN }).first()
      log.debug('Result: ', result)
      if (result) {
        setUser(result)
      }
      setState(State.LOADED)
    } catch (error) {
      log.error(error)
      setState(State.ERROR)
    }
  }

  useEffect(() => {
    getCurrentUser()
  }, [])

  const onUpdateUser = (user: CurrentUser | null) => {
    setUser(user)
  }

  const didLogout = () => {
    db.currentUser.clear().then(res => {
      window.location.href = '/'
    })
  }

  if (state === State.LOADING) {
    return <Container className='d-flex justify-content-center align-items-center' style={{ height: '100vh' }}>
      <LoadingView />
    </Container>
  }

  return (
    <IntlProvider locale={i18nConfig.language} messages={i18nConfig.messages}>
      <UserContext.Provider value={{ user, updateUser: onUpdateUser }}>
        <BrowserRouter>
          <Routes>
            <Route path='/' element={<Main />} >
              <Route index element={<Home />} />
              <Route path='about' element={<About />} />
              <Route path='contact' element={<Contact />} />
              <Route path='login' element={<Login />} />
              <Route path='logout' element={<Logout didLogout={didLogout} />} />
              <Route path='song' element={<Song />} >
                <Route path=':audioId' element={<SongDetailView />} />
              </Route>
              <Route path='split' element={<Split />} >
                <Route path=':providerId' element={<SplitDetailView />} />
              </Route>
              <Route path='karaoke' element={<KaraokeView />} >
                <Route path=':audioFileId' element={<KaraokePlayerView />} />
                <Route path=':audioFileId/lyrics' element={<KaraokeLyricsView />} />
              </Route>
              <Route path='player' element={<PlayerView />} >
                <Route path=':providerId' element={<PlayerAudio />} />
              </Route>
              <Route path='search' element={<Search />} />
            </Route>
            <Route path='/:usernameOrId' element={<Main />} >
              <Route index element={<ProfileRootView />} />
              <Route element={<ProfileNetworksRootView />}>
                <Route path='followers' element={<ProfileFollowersRootView />} />
                <Route path='following' element={<ProfileFollowingRootView />} />
              </Route>
            </Route>
          </Routes>
        </BrowserRouter>
      </UserContext.Provider>
    </IntlProvider >
  );
}