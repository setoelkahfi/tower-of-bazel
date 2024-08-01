namespace :api do
  root to: 'welcome#index'

  namespace :v1 do
    root to: 'welcome#index'

    devise_scope :user do
      post      '/register'                     => 'user#register'
      post      '/login'                        => 'user#login'
      delete    '/logout'                       => 'user#logout'
      get       '/splitfire/:id'                => 'audio_file#splitfire_detail'
      get       '/profile/:username'            => 'user#profile'
      get       '/profile/:username/following'  => 'user#following'
      get       '/profile/:username/followers'  => 'user#followers'
    end

    get     '/splitfire',             to: 'audio_file#splitfire'
    post    '/user_files',            to: 'audio_file#user_files'
    post    '/split',                 to: 'audio_file#split'
    post    '/karaoke',               to: 'audio_file#karaoke'
    post    '/guitar_backing_track',  to: 'audio_file#guitar_backing_track'
    post    '/bass_backing_track',    to: 'audio_file#bass_backing_track'
    post    '/drum_backing_track',    to: 'audio_file#drum_backing_track'

    get     '/community/:exclude', to: 'user#community'

    get     '/lyric_synches/:audio_file_id', to: 'karaoke#lyric_synches'
    post    '/lyric_synches/:audio_file_id', to: 'karaoke#lyric_synches_post'
    put     '/lyric_synches/:audio_file_id', to: 'karaoke#lyric_synches_put'

    # Search
    get     '/search',              to: 'search#index' # Autocomplete
    post    '/search',              to: 'search#post'  # Save search history
    # Gamelan notation
    get     '/gamelan/:id',         to: 'gamelan#detail'

    # Find audio from a Spotify track
    get '/carousel',                to: 'song_bridge#carousel'
    get '/top-votes',               to: 'song_bridge#top_votes'
    get '/ready-to-play',           to: 'song_bridge#ready_to_play'
    post '/song-bridge',            to: 'song_bridge#add_song_provider'
    get '/song-bridge/:id',         to: 'song_bridge#find_audio'
    get '/song-bridge/:id/detail',  to: 'song_bridge#detail'
    post '/song-bridge/:id/vote',   to: 'song_bridge#vote'

    get '/:platform', to: 'welcome#root'
  end
end
