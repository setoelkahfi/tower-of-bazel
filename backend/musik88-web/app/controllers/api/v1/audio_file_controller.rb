module Api
  module V1
    # Fix this later
    # rubocop:disable Metrics/ClassLength
    class AudioFileController < ApplicationController
      skip_before_action :verify_authenticity_token

      MAX_AUDIO_LENGTH_IN_MINUTES = 8

      def splitfire
        @audio_files = AudioFile.order(Arel.sql('random()')).limit(5)
        render_user_files
      end

      def splitfire_detail
        return render_error 'We need the id.' if params[:id].nil?

        begin
          @audio_file_id = Integer(params[:id])
        rescue ArgumentError
          return render_error 'id should be integer.'
        end

        @audio_file = AudioFile.find_by(id: @audio_file_id)

        return render_error 'File not found' unless @audio_file

        render_file
      end

      def user_files
        return render_error 'We need the userId.' if params[:userId].nil?

        begin
          user_id = Integer(params[:userId])
        rescue ArgumentError
          return render_error 'userId should be integer.'
        end

        @audio_files = AudioFile.where(user_id: user_id).all.with_attached_source_file.order(created_at: :desc)
        render_user_files
      end

      # Split request
      def split
        logger.info 'Split request'
        return render_error 'You must login.' unless current_user.present?

        provider_id = params[:provider_id]
        return render_error 'We need the provider id.' if provider_id.nil?

        process_song_provider(provider_id)
      end

      def karaoke
        return unless valid_request?

        if @audio_file.karaoke_file.present?
          render json: {
            code: 500,
            message: 'We are processing this file.'
          }
          return
        end

        AudioFileKarokoweStatus.new(
          audio_file_id: @audio_file.id,
          status: :processing,
          processing_progress: 3
        ).save

        KarokoweJob.perform_later(@audio_file.id)

        render json: {
          code: 200,
          message: 'KaroKowe is generating karaoke file for you.'
        }
      end

      def guitar_backing_track
        return unless valid_request?

        if @audio_file.guitar_backing_track_file.present?
          render json: {
            code: 500,
            message: 'We are processing this file.'
          }
          return
        end

        GuitarBackingTrackJob.perform_later(@audio_file.id)

        render json: {
          code: 200,
          message: 'We are generating guitar backing track file for you.'
        }
      end

      def bass_backing_track
        return unless valid_request?

        if @audio_file.bass_backing_track_file.present?
          render json: {
            code: 500,
            message: 'We are processing this file.'
          }
          return
        end

        BassBackingTrackJob.perform_later(@audio_file.id)

        render json: {
          code: 200,
          message: 'We are generating bass backing track file for you.'
        }
      end

      def drum_backing_track
        return unless valid_request?

        if @audio_file.drum_backing_track.present?
          render json: {
            code: 500,
            message: 'We are processing this file.'
          }
          return
        end

        DrumBackingTrackJob.perform_later(@audio_file.id)

        render json: {
          code: 200,
          message: 'We are generating drum backing track file for you.'
        }
      end

      private

      def render_error(message)
        logger.error message
        render json: { code: 500, message: message, audio_files: [] }, status: :unprocessable_entity
      end

      def render_file
        render json: {
          code: 200,
          message: 'OK.',
          audio_file: @audio_file.as_json_packed.merge(render_file_results)
        }, status: :ok
      end

      def render_file_results
        {
          results: @audio_file.splitfire_results.map do |result|
            result.as_json(only: :id).merge({
                                              filename: result.source_file.filename,
                                              source_file: polymorphic_url(result.source_file),
                                              length: result.length,
                                              onset: result.onset
                                            })
          end
        }
      end

      # Render audio_file as json
      def render_success_split_request(audio_file)
        render json: { code: 200, message: 'SplitFire is processing this file for you.', audio_file: audio_file },
               status: :ok
      end

      def render_user_files
        audio_files = @audio_files.map do |audio_file|
          filename = ''
          source_file = ''

          if !audio_file.source_file.nil? && audio_file.source_file.attached?
            filename = audio_file.source_file.filename
            source_file = polymorphic_url(audio_file.source_file) unless audio_file.source_file.nil?
          end

          # Karaoke file
          if !audio_file.karaoke_file.nil? && !audio_file.karaoke_file.source_file.nil? && audio_file.karaoke_file.source_file.attached?
            karaoke_filename = audio_file.karaoke_file.source_file.filename
            unless audio_file.karaoke_file.source_file.nil?
              karaoke_source_file = polymorphic_url(audio_file.karaoke_file.source_file)
            end

            karaoke_file = audio_file.karaoke_file.as_json.merge({
                                                                   filename: karaoke_filename,
                                                                   source_file: karaoke_source_file
                                                                 })
          end

          # Guitar backing track
          if audio_file.guitar_backing_track_file.present?
            if audio_file.guitar_backing_track_file.source_file.attached?
              filename    = audio_file.guitar_backing_track_file.source_file.filename
              source_file = polymorphic_url(audio_file.guitar_backing_track_file.source_file)
            end

            guitar_backing_track_file = audio_file.guitar_backing_track_file.as_json.merge({
                                                                                             filename: filename,
                                                                                             source_file: source_file
                                                                                           })
          end

          # Bass backing track
          if audio_file.bass_backing_track_file.present?
            if audio_file.bass_backing_track_file.source_file.attached?
              filename    = audio_file.bass_backing_track_file.source_file.filename
              source_file = polymorphic_url(audio_file.bass_backing_track_file.source_file)
            end

            bass_backing_track_file = audio_file.bass_backing_track_file.as_json.merge({
                                                                                         filename: filename,
                                                                                         source_file: source_file
                                                                                       })
          end

          # Drum backing track
          if audio_file.drum_backing_track.present?
            if audio_file.drum_backing_track.source_file.attached?
              filename    = audio_file.drum_backing_track.source_file.filename
              source_file = polymorphic_url(audio_file.drum_backing_track.source_file)
            end

            drum_backing_track_file = audio_file.drum_backing_track.as_json.merge({
                                                                                    filename: filename,
                                                                                    source_file: source_file
                                                                                  })
          end

          audio_file.as_json.merge({
                                     user: audio_file.user.as_json,
                                     status: audio_file.audio_file_split_status,
                                     status_karaoke: audio_file.audio_file_karokowe_status,
                                     filename: filename,
                                     source_file: source_file,
                                     youtube_thumbnail: audio_file.youtube_thumbnail,
                                     results: audio_file.splitfire_results.map do |result|
                                                result.as_json.merge({
                                                                       filename: result.source_file.filename,
                                                                       source_file: polymorphic_url(result.source_file)
                                                                     })
                                              end,
                                     karaoke_file: karaoke_file,
                                     guitar_backing_track_file: guitar_backing_track_file,
                                     bass_backing_track_file: bass_backing_track_file,
                                     drum_backing_track_file: drum_backing_track_file
                                   })
        end

        render json: {
          code: 200,
          message: 'OK',
          audio_files: audio_files
        }
      end

      # provider_id is the ActiveRecord id of the SongProvider
      def process_song_provider(provider_id)
        # Find song provider by provider_id
        song_provider = SongProvider.find(provider_id)
        # Make sure the song provider is found and provider_type is youtube
        return render_error 'Song provider not found.' if song_provider.nil? || song_provider.provider_type != 'youtube'

        # Make sure it's a valid youtube url
        return render_error 'Invalid youtube url.' unless valid_youtube_link?(song_provider.preview_url)

        # Make sure video length is valid
        unless valid_audio_length?(song_provider)
          return render_error "Less than #{MAX_AUDIO_LENGTH_IN_MINUTES} minutes, please."
        end

        # We are good to go
        process_youtube_link(song_provider)
      end

      def process_youtube_link(song_provider)
        audio_file = AudioFile.new(song_provider_id: song_provider.id, status: :downloading, progress: 0)
        return render_error 'Cannot create AudioFile record.' unless audio_file.save

        YoutubeToAudioJob.perform_later(song_provider.id)
        render_success_split_request(song_provider.audio_file)
      end

      def valid_audio_length?(song_provider)
        length_string   = `yt-dlp --get-duration #{song_provider.preview_url}`
        length_strings  = length_string.split(':')
        # We should have two elements, minutes and seconds
        return false unless length_strings.count == 2

        # We only care about the minutes part
        length_strings.first.to_i <= MAX_AUDIO_LENGTH_IN_MINUTES
      end

      def valid_url?(url)
        uri = URI.parse(url)
        uri.is_a?(URI::HTTP) && !uri.host.nil?
      rescue URI::InvalidURIError
        false
      end

      def valid_youtube_link?(youtube_video_url)
        uri = URI.parse(youtube_video_url)

        return false unless !uri.host.nil? && (uri.host.include?('youtube.com') || uri.host.include?('youtu.be'))

        # To make things simple, we only recognize youtube.com and youtu.be
        youtube_video_url =~ %r{^https*://[www.]*youtu[.]{1}*be[.com]{4}*/[watch?v=]*([a-zA-Z0-9_-]*)}
      end

      def valid_request?
        audio_id_param = params[:audioId]

        unless !audio_id_param.nil? && !audio_id_param.empty?
          render json: {
            code: 500,
            message: 'We need the audioId.',
            audio_files: []
          }
          return false
        end

        begin
          audio_id = Integer(audio_id_param)
        rescue ArgumentError
          render json: {
            code: 500,
            message: 'audioId should be integer.',
            audio_files: []
          }
          return false
        end

        @audio_file = AudioFile.find_by(id: audio_id)

        unless @audio_file.present?
          render json: {
            code: 500,
            message: 'I dont know what is happening. Sorry.'
          }
          return false
        end

        true
      end
    end
  end
end
