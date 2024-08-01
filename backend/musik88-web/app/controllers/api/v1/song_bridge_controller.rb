# frozen_string_literal: true

module Api
  module V1
    class SongBridgeController < ApiController
      before_action :authenticate_user!, only: %i[add_song_provider vote]

      def add_song_provider
        find_song_provider
        if @song_provider.present?
          return render json: { code: 200, message: 'Song provider already exists' }, status: :ok
        end

        find_or_create_base_song
        create_song_provider
        render json: { code: 200, message: 'Song provider created', song: @song }, status: :created
      end

      def find_audio
        # Get the Spotify track ID from the URL
        song_provider = SongProvider.find(params[:id])
        song = song_provider.song || Song.create(name: song_provider.name, user_id: song_provider.user_id)
        # Find available Spotify token
        authorization = User.joins(:user_setting).where(user_setting: { allowed_use_spotify_token: true }).first.spotify
        # If no available Spotify token, return
        return render json: { error: 'No available Spotify token' }, status: :unprocessable_entity unless authorization

        # Create Spotify client
        client = SpotifyClient.new(authorization)
        # Call Spotify API
        response = client.get_track(song_provider.provider_id)
        # Parse response
        spotify_track = JSON.parse(response.body)
        p spotify_track
        images = []
        images = spotify_track['album']['images'] if spotify_track['error'].nil?
        album_name = ''
        album_name = spotify_track['album']['name'] if spotify_track['error'].nil?

        youtubes = SongProvider
                   .where(
                     'lower(description) LIKE ? AND provider_type = 1',
                     "%#{song_provider.name}%"
                   )
                   .limit(10)
                   .as_json(only: %i[id name provider_id image_url])

        render json: {
          code: 200,
          name: song_provider.name,
          album_name: album_name,
          images: images,
          items: youtubes || []
        }
      end

      def vote
        song_provider = SongProvider.find_by(id: params[:provider_id])
        insert_or_remove_vote

        render json: { code: 200, message: 'Song provider found.', song_provider: song_provider,
                       votes: song_provider.song_provider_vote },
               status: :ok
      end

      def detail
        @provider = SongProvider.find_by(id: params[:id], provider_type: :youtube)
        return render json: { code: 404, message: 'Song provider not found' }, status: :not_found unless @provider

        render_song_provider
      end

      def carousel
        @songs = SongProvider.where(provider_type: :youtube).order(Arel.sql('random()')).limit(15)
        render json: {
          code: 200,
          message: 'OK',
          audio_files: @songs
        }
      end

      def top_votes
        # Find most voted song providers
        @songs = SongProvider.joins(:song_provider_vote).group(:id).order('count(song_provider_votes.id) DESC').limit(20)
        render json: {
          code: 200,
          message: 'OK',
          audio_files: @songs
        }
      end

      def ready_to_play
        # Find all songs that are ready to play
        @songs = SongProvider.where(audio_file: { status: :done }, status: :published).joins(:audio_file)
        render json: {
          code: 200,
          message: 'OK',
          audio_files: @songs
        }
      end

      private

      def find_song_provider
        provider_id = params[:provider_id]
        provider = SongProvider.provider_types[params[:provider]]
        @song_provider = SongProvider.find_by(provider_id: provider_id, provider_type: provider)
      end

      def create_song_provider
        provider_id = params[:provider_id]
        name = params[:name]
        provider = SongProvider.provider_types[params[:provider]]
        @song_provider = SongProvider.create(
          provider_id: provider_id,
          name: name,
          provider_type: provider,
          user_id: current_user.id,
          song_id: @song.id
        )
      end

      def find_or_create_base_song
        reference = SongProvider.find(params[:reference_id])
        @song = if reference.song.present?
                  reference.song
                else
                  Song.create(
                    name: reference.name,
                    user_id: current_user.id
                  )
                end
      end

      def insert_or_remove_vote
        vote_type = params[:vote_type]
        provider_id = params[:provider_id]
        # This should be validated in the front end
        @vote = SongProviderVote.find_by(user_id: current_user.id, song_provider_id: provider_id)
        # If vote exists, remove it.
        if @vote.present?
          @vote.destroy
        else
          @vote = SongProviderVote.new(user_id: current_user.id, song_provider_id: provider_id, vote_type: vote_type)
          @vote.save
        end
      end

      def render_song_provider
        render json: { code: 200, message: 'Song provider found', song_provider: @provider,
                       votes: @provider.song_provider_vote }, status: :ok
      end

      def process_song_provider
        @audio_file = AudioFile.new(status: :downloading, song_provider_id: @provider.id)
        @audio_file.save

        YoutubeToAudioJob.perform_later(@provider.id)

        # Update provider
        @provider = @audio_file.song_provider
        render_song_provider
      end
    end
  end
end
