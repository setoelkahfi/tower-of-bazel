# frozen_string_literal: true

class SpotifyClient
  BASE_URI = 'https://api.spotify.com/v1'
  BASE_URI_ACCOUNT = 'https://accounts.spotify.com/api'
  LIMIT = 50

  def initialize(authorization)
    raise 'Authorization is required' if authorization.nil?

    @authorization = authorization
    @token = authorization.token
  end

  def user_top_items_request(type, time_range)
    uri = "#{BASE_URI}/me/top/#{type}"
    query = { 'time_range' => time_range, 'limit' => LIMIT }
    header = [
      ['Accept', 'application/json'],
      ['Content-Type', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get(uri, query, header)
  end

  def user_recently_played_request
    uri = "#{BASE_URI}/me/player/recently-played"
    query = { 'limit' => LIMIT }
    header = [
      ['Accept', 'application/json'],
      ['Content-Type', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get(uri, query, header)
  end

  def album_tracks_request(album_id)
    uri = "#{BASE_URI}/albums/#{album_id}/tracks"
    query = { 'limit' => LIMIT }
    header = [
      ['Accept', 'application/json'],
      ['Content-Type', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get(uri, query, header)
  end

  def artist_detail_request(artist_id)
    uri = "#{BASE_URI}/artists/#{artist_id}"
    get(uri, {})
  end

  def get_track(track_id)
    uri = "#{BASE_URI}/tracks/#{track_id}"
    get(uri, {})
  end

  private

  def client
    HTTPClient.new
  end

  def get(uri, query)
    header = [
      ['Accept', 'application/json'],
      ['Content-Type', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    response = client.get(uri, query, header)
    return_or_refresh(response, uri, query)
  end

  def return_or_refresh(response, uri, query)
    return response if response.status != 401

    refresh_access_token do
      get(uri, query)
    end
  end

  def refresh_access_token
    header = [
      ['Accept', 'application/json'],
      ['Content-Type', 'application/x-www-form-urlencoded'],
      ['Authorization', "Basic #{Base64.strict_encode64("#{ENV['SPOTIFY_APP_ID']}:#{ENV['SPOTIFY_APP_SECRET']}")}"]
    ]
    body = { 'grant_type' => 'refresh_token', 'refresh_token' => @authorization.refresh_token }
    response = client.post("#{BASE_URI_ACCOUNT}/token", body, header)
    update_authorization(JSON.parse(response.body))
    yield
  end

  def update_authorization(response)
    @token = response['access_token']
    @authorization.update(token: @token)
    @authorization.update(refresh_token: response['refresh_token']) if response['refresh_token'].present?
  end
end
