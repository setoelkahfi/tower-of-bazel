get     'artist',                   to: 'artists#index',              as: :artist
get     'artist_add',               to: 'artists#add',                as: :artist_add
post    'artist_add',               to: 'artists#add',                as: :artist_add
post    'artist_vote',              to: 'artists#vote'
delete  'artist_unvote',            to: 'artists#unvote'
get     'album',                    to: 'albums#index',               as: :album
get     'album_add',                to: 'albums#add',                 as: :album_add
post    'album_add',                to: 'albums#add',                 as: :album_add
post    'album_vote',               to: 'albums#vote'
delete  'album_unvote',             to: 'albums#unvote'
get     'song',                     to: 'songs#index',                as: :song
get     'song_add',                 to: 'songs#add',                  as: :song_add
post    'song_add',                 to: 'songs#add',                  as: :song_add
get     'song_karaoke_detail',      to: 'songs#karaoke',              as: :song_karaoke_detail
get     'song_bass_backing_track',  to: 'songs#bass_backing_track',   as: :song_bass_backing_track
get     'song_bass_tab',            to: 'songs#bass_tab',             as: :song_bass_tab

post    'song_chord_pleas_loved',   to: 'songs#loved'
delete  'song_chord_pleas_unloved', to: 'songs#unloved'

get     'most_loved_songs',         to: 'songs#most_loved',           as: :most_loved_songs

get     'song_lyrics',              to: 'lyrics#index',               as: :lyrics
get     'song_lyrics_detail',       to: 'lyrics#lyric',               as: :lyric_detail
get     'guitar_chords',            to: 'chords#index',               as: :guitar_chords
get     'guitar_chord_shapes',      to: 'chords#guitar_shapes',       as: :guitar_chord_shapes
get     'guitar_chord_shape',       to: 'chords#guitar_shape',        as: :guitar_chord_shape
get     'guitar_chords_detail',     to: 'chords#chord',               as: :guitar_chord_detail
get     'guitar_chords_history',    to: 'chords#history',             as: :guitar_chord_history
get     'guitar_chords_add',        to: 'chords#add',                 as: :guitar_chord_add
post    'guitar_chords_add',        to: 'chords#add_post',            as: :guitar_chord_add
get     'guitar_chords_add_song_search',  to: 'chords#song_search',         as: :guitar_chord_add_song_search
get     'guitar_chords_review',           to: 'chords#review',              as: :guitar_chord_review
patch   'guitar_chords_review',           to: 'chords#review',              as: :guitar_chord_review
post    'chord_vote',                     to: 'chords#vote'
delete  'chord_unvote',                   to: 'chords#unvote'

get 'artist_detail/:slug',  to: 'artists#detail', as: :artist_detail    # slug is artist name + id
get 'artist_bridge/:slug',  to: 'artists#bridge', as: :artist_bridge    # slug is artist name + id
get 'album_detail/:slug',   to: 'albums#detail',  as: :album_detail     # slug is album name + artist name + id
get 'album_bridge/:slug',   to: 'albums#bridge',  as: :album_bridge     # slug is album name + artist name + id
get 'song_detail/:slug',    to: 'songs#detail',   as: :song_detail      # slug is song title + artist name + album + id
get 'song_bridge/:slug',    to: 'songs#bridge',   as: :song_bridge      # slug is song title + artist name + album + id
get 'song_chords/:slug',    to: 'songs#chords',   as: :song_chords
get 'song_lyrics/:slug',    to: 'songs#lyrics',   as: :song_lyrics
get 'song_audio/:slug',     to: 'songs#audio',    as: :song_audio

get   'audio_files',          to: 'audio_files#index',                as: :audio_files
get   'guitar_backing_track', to: 'audio_files#guitar_backing_track', as: :guitar_backing_track
post  'guitar_backing_track', to: 'audio_files#guitar_backing_track', as: :guitar_backing_track
get   'bass_backing_track',   to: 'audio_files#bass_backing_track',   as: :bass_backing_track
post  'bass_backing_track',   to: 'audio_files#bass_backing_track',   as: :bass_backing_track
get   'drum_backing_track',   to: 'audio_files#drum_backing_track',   as: :drum_backing_track
post  'drum_backing_track',   to: 'audio_files#drum_backing_track',   as: :drum_backing_track

# What is?
get 'what_is_this', to: 'pages#what_is_this', as: :what_is_this
get 'what_is_this_detail', to: 'pages#what_is_this_detail', as: :what_is_this_detail
