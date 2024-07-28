require 'google/apis/youtube_v3'
require 'google/api_client/client_secrets'

# Fix this later
# rubocop:disable Metrics/ClassLength
class YoutubeClient
  BASE_URI = 'https://youtube.googleapis.com/youtube/v3'.freeze

  def initialize(authorization)
    raise 'Authorization is required' if authorization.nil?

    @authorization = authorization
    @token = authorization.token
    @youtube_export_playlist_count = 0
    @youtube_export_playlist_items_count = 0
  end

  def youtube_export_playlist_max_iteration
    # If development, set to 2, else 10.
    Rails.env.development? ? 2 : 10
  end

  # Personal content
  def search_personal(_keywords)
    results = service.list_searches('snippet', for_mine: false, q: 'dewa', type: 'video',
                                               options: { authorization: auth_client })
    p results
  end

  def search(keywords)
    uri = 'https://www.googleapis.com/youtube/v3/search'
    client = HTTPClient.new
    query = { 'key' => 'AIzaSyDhs0-L3B6X_oq0cVn7GIPgvmb5--VlecE', 'q' => keywords, 'type' => 'video',
              'part' => 'snippet' }
    header = [
      ['Accept', 'application/json'],
      ['Content-Type', 'application/json']
    ]
    client.get(uri, query, header)
  end

  def user_likes_videos(next_page_token = nil)
    query = { 'key' => ENV['GOOGLE_API_KEY'], 'myRating' => 'like', 'part' => 'snippet,contentDetails,statistics',
              'maxResults' => '50', 'pageToken' => next_page_token }
    header = [
      ['Accept', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get("#{BASE_URI}/videos", query, header)
  end

  # Get user's playlists list
  def export_user_playlist(next_page_token = nil)
    @youtube_export_playlist_count += 1
    response = get_user_playlist(next_page_token)
    response_json = JSON.parse(response.body)
    # Return if no playlist found
    return if response_json['items'].nil?

    # Loop through all playlists items
    response_json['items'].each do |playlists|
      # Get playlist items
      export_user_playlist_items(playlists['id'])
    end

    # Check playlist pagination
    if response_json['nextPageToken'].present? && @youtube_export_playlist_count < youtube_export_playlist_max_iteration
      export_user_playlist(response_json['nextPageToken'])
    end
  end

  private

  def client
    HTTPClient.new
  end

  def service
    @service ||= Google::Apis::YoutubeV3::YouTubeService.new
  end

  def auth_client
    @auth_client ||= Signet::OAuth2::Client.new(access_token: @token)
  end

  def get_user_playlist(next_page_token = nil)
    query = { 'key' => ENV['GOOGLE_API_KEY'], 'maxResults' => '50', 'mine' => true,
              'pageToken' => next_page_token }
    header = [
      ['Accept', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get("#{BASE_URI}/playlists", query, header)
  end

  def export_user_playlist_items(playlist_id, next_page_token = nil)
    @youtube_export_playlist_items_count += 1
    response = get_user_playlist_items(playlist_id, next_page_token)
    response_json = JSON.parse(response.body)

    # Get video ids from playlist items, separated by comma
    video_ids = response_json['items'].map { |item| item['contentDetails']['videoId'] }.join(',')
    p "Exporting playlist items: #{video_ids}"
    get_videos_from_playlist_video_ids(video_ids)

    # Check playlist items pagination
    if response_json['nextPageToken'].present? && @youtube_export_playlist_items_count < youtube_export_playlist_max_iteration
      export_user_playlist_items(playlist_id, response_json['nextPageToken'])
    end
  end

  def get_user_playlist_items(id, next_page_token = nil)
    query = { 'key' => ENV['GOOGLE_API_KEY'], 'part' => 'snippet,contentDetails', 'maxResults' => '50',
              'playlistId' => id, 'pageToken' => next_page_token }
    header = [
      ['Accept', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get("#{BASE_URI}/playlistItems", query, header)
  end

  def get_videos_from_playlist_video_ids(video_ids)
    response = user_videos({ 'id' => video_ids })
    response_json = JSON.parse(response.body)
    p "Exporting videos from playlist: #{response_json}"
    export_youtube_videos(response_json['items'], @authorization.user_id)
  end

  def export_youtube_videos(items, user_id)
    music_videos = items.select { |item| item['snippet']['categoryId'] == '10' }
    music_videos.each do |video|
      SongProvider.upsert(
        { user_id: user_id, provider_type: :youtube, provider_id: video['id'], name: video['snippet']['title'],
          preview_url: "https://www.youtube.com/watch?v=#{video['id']}", description: video['snippet']['description'],
          image_url: video['snippet']['thumbnails']['high']['url'] },
        unique_by: :index_song_providers_on_provider_id_and_provider_type
      )
    end
  end

  def user_videos(additional_query, next_page_token = nil)
    p "Additional query: #{additional_query}"
    query = { 'key' => ENV['GOOGLE_API_KEY'], 'part' => 'snippet,contentDetails,statistics',
              'maxResults' => '50', 'pageToken' => next_page_token }
    query = query.merge(additional_query)
    p "Query: #{query}"
    header = [
      ['Accept', 'application/json'],
      ['Authorization', "Bearer #{@token}"]
    ]
    client.get("#{BASE_URI}/videos", query, header)
  end
end
