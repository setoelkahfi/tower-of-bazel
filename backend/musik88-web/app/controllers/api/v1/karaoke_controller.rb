module Api
  module V1
    class KaraokeController < ApiController
      before_action :validate_request

      def lyric_synches
        render_file
      end

      def lyric_synches_post
        return unless valid_payload?

        @payload.map do |lyric_synch|
          lyric_synch.delete('id')
          lyric_synch['audio_file_id'] = params[:audio_file_id]
          lyric_synch['user_id'] = current_user.id
        end

        LyricSynch.insert_all(@payload)
        render_file
      end

      def lyric_synches_put
        return unless valid_payload?

        LyricSynch.upsert_all(@payload, unique_by: :id)
        render_file
      end

      private

      def validate_request
        return render_error 'You must login.' unless user_signed_in?

        return render_error 'We need the id.' if params[:audio_file_id].nil?

        begin
          @audio_file_id = Integer(params[:audio_file_id])
        rescue ArgumentError
          return render_error 'audio_file_id should be integer.'
        end

        true
      end

      def valid_payload?
        information = request.raw_post
        data_parsed = JSON.parse(information)
        @payload    = data_parsed['payload']
        if @payload.nil?
          render_error 'We need the payload.'
          return false
        end

        true
      end

      def render_error(message)
        render json: {
          code: 500,
          message: message,
          audio_files: []
        }
      end

      def render_file
        @lyric_synches = LyricSynch.where(audio_file_id: @audio_file_id)
        render json: {
          code: 200,
          message: 'OK.',
          lyric_synches: @lyric_synches.as_json(only: %i[id lyric time])
        }
      end
    end
  end
end
