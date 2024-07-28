# frozen_string_literal: true

module Api
  module V1
    class GamelanController < ApiController

      def detail
        id = params[:id]
        @notation = JavaneseGendingNotation.find(id)
        render json: @notation.as_json_packed
      end
    end
  end
end
