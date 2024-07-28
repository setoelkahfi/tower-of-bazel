# frozen_string_literal: true

class SpotifyOnboardingExportJob < ApplicationJob
  queue_as :default

  def perform(user_id, time_range)
    @user = User.find_by_id(user_id)
    @time_range = time_range || 'medium_term'
    @client = SpotifyClient.new(@user&.spotify)

    spotify_export_artist
    spotify_export_tracks
  end

  private

  def spotify_export_artist
    res = @client.user_top_items_request('artists', @time_range)
    response = JSON.parse(res.body)
    items = response['items']
    # p response
    items&.each do |item|
      # p "spotify_export_artist: #{item}"
      artist = ArtistProvider.find_by(provider_id: item['id'], provider_type: provider_type)
      add_artist(item) if artist.nil?
    end
  end

  def add_artist(item)
    genres = item['genres'].nil? ? '' : item['genres'].join(',')

    artist = ArtistProvider.new(user_id: @user.id, provider_id: item['id'],
                                provider_type: provider_type,
                                name: item['name'], genres: genres)
    return unless artist.save
  end

  def spotify_export_tracks
    res = @client.user_top_items_request('tracks', @time_range)
    response = JSON.parse(res.body)
    items = response['items']

    items&.each do |item|
      # p "spotify_export_tracks: #{item}"
      # Export tracks from the album.
      # Do not export track directly.
      export_album_if_possible(item['album'])
    end
  end

  def export_artists_from_tracks(artists)
    artists.each do |artist|
      artist_provider = ArtistProvider.find_by(provider_id: artist['id'],
                                               provider_type: provider_type)
      add_artist(artist) if artist_provider.nil?
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
      export_song_if_possible(item, album_id)
    end
  end

  def export_song_if_possible(song, _album_id)
    song_provider = SongProvider.find_by(provider_id: song['id'], provider_type: provider_type)
    if song_provider.nil?
      song_provider = SongProvider.new(user_id: @user.id, provider_id: song['id'], provider_type: provider_type,
                                       name: song['name'], preview_url: song['preview_url'])
      song_provider.save
    end
  end

  def provider_type
    ArtistProvider.provider_types[:spotify]
  end
end
