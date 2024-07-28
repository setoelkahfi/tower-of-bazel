# frozen_string_literal: true

module Api
  module V1
    class SearchController < ApiController
      QUERY_LIMIT_AUTOCOMPLETE = 5

      def index
        keyword = params[:q].downcase
        client = params[:client].to_sym
        render json: {
          results: merge_search(keyword, client, QUERY_LIMIT_AUTOCOMPLETE)
        }
      end

      # Save search history
      def post
        search_term = params[:term]
        logger.info "Search term: #{search_term}"
        # Append cound if search term exists
        search_history = SearchTerm.find_by(term: search_term)
        if search_history
          search_history.increment!(:count)
        else
          SearchTerm.new(term: search_term, count: 1).save
        end

        render json: { message: 'Ok.' }, status: :ok
      end

      private

      def merge_search(keyword, client, limit)
        case client
        when :web_beta
          merge_search_web_beta(keyword, limit)
        when :web_v1, :web_v1_localhost
          merge_search_web_v1(keyword, limit)
        when :splitfire
          merge_search_splitfire(keyword, limit)
        else
          merge_search_splitfire(keyword, limit)  # Remove this after we add client param to splitfire
        end
      end

      def merge_search_web_beta(keywords, limit)
        search_gending_notation(keywords, limit) + search_gending(keywords, limit) +
          search_artist(keywords, limit) + search_song(keywords, limit) + search_album(keywords, limit)
      end

      def merge_search_web_v1(keywords, limit)
        logger.debug "merge_search_web_v1: Searching for #{keywords}"
        search_gending_notation(keywords, limit) + search_gending(keywords, limit)
      end

      def merge_search_splitfire(keywords, limit)
        search_song(keywords, limit)
      end

      def search_song(keywords, limit)
        SongProvider
          .where('lower(name) LIKE ? AND provider_type = 0', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name])
      end

      def search_gending_notation(keywords, limit)
        JavaneseGendingNotation
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name])
      end

      def search_artist(keywords, limit)
        Artist
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name]) +
          search_artist_provider(keywords, limit)
      end

      def search_album(keywords, limit)
        Album
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name]) +
          search_album_provider(keywords, limit)
      end

      def search_album_provider(keywords, limit)
        AlbumProvider
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name])
      end

      def search_artist_provider(keywords, limit)
        ArtistProvider
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name])
      end

      def search_song_provider(keywords, limit)
        SongProvider
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name])
      end

      def search_gending(keywords, limit)
        JavaneseGending
          .where('lower(name) LIKE ?', "%#{keywords}%")
          .limit(limit)
          .as_json(only: %i[id name])
      end
    end
  end
end
