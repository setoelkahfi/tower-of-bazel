# frozen_string_literal: true

class SpotifySyncExportJob < ApplicationJob
  def perform(user_id)
    @user = User.find_by_id(user_id)
    @client = SpotifyClient.new(@user&.spotify)

    spotify_export_recently_played
  end

  private

  def spotify_export_recently_played
    res = @client.user_recently_played_request
    response = JSON.parse(res.body)
    # p response
    items = response['items']

    items&.each do |item|
      # Export tracks and artists from the album.
      # Do not export them directly.
      export_album_if_possible(item['track']['album'])
    end
  end

  def export_album_if_possible(album)
    album_provider = AlbumProvider.find_by(provider_id: album['id'],
                                           provider_type: provider_type)
    if album_provider.nil?
      album_provider = AlbumProvider.new(user_id: @user.id, provider_id: album['id'],
                                         provider_type: provider_type,
                                         name: album['name'])
      return unless album_provider.save
    end

    # ActiveRecord id, Spotify id
    export_album_tracks(album_provider.id, album_provider.provider_id)
  end

  def export_album_tracks(album_id, album_provider_id)
    res = @client.album_tracks_request(album_provider_id)
    response = JSON.parse(res.body)
    items = response['items']

    items&.each do |item|
      export_song_if_possible(item)
    end
  end

  def export_song_if_possible(song)
    song_provider = SongProvider.find_by(provider_id: song['id'], provider_type: provider_type)
    if song_provider.nil?
      song_provider = SongProvider.new(user_id: @user.id, provider_id: song['id'], provider_type: provider_type,
                                       name: song['name'], preview_url: song['preview_url'])
      song_provider.save
    end

    # Export all artists for this song, and add it to song_artists table
    export_song_artists(song_provider.id, song['artists'])
  end

  def export_song_artists(song_provider_id, artists)
    artists&.each do |artist|
      artist_provider = ArtistProvider.find_by(provider_id: artist['id'], provider_type: provider_type)
      if artist_provider.nil?
        export_song_artist(artist['id'], song_provider_id)
        next
      end

      add_song_artist_if_needed(song_provider_id, artist_provider.id)
    end
  end

  def add_song_artist_if_needed(song_provider_id, _artist_provider_id)
    song_artist = SongArtist.find_by(song_provider_id: song_provider_id)
    return unless song_artist.nil?

    song_artist = SongArtist.new(song_provider_id: song_provider_id)
    song_artist.save
  end

  def export_song_artist(artist_id, song_provider_id)
    response = @client.artist_detail_request(artist_id)
    response_json = JSON.parse(response.body)
    # p response_json
    add_artist_provider(response_json, song_provider_id)
  end

  def add_artist_provider(artist, song_provider_id)
    genres = artist['genres'].nil? ? '' : artist['genres'].join(',')

    artist = ArtistProvider.new(user_id: @user.id, provider_id: artist['id'],
                                provider_type: provider_type,
                                name: artist['name'], genres: genres)
    return unless artist.save

    add_song_artist_if_needed(song_provider_id, artist.id)
  end

  def provider_type
    ArtistProvider.provider_types[:spotify]
  end
end
