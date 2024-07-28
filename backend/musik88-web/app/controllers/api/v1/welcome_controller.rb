module Api
  module V1
    class WelcomeController < ApplicationController
      def index
        @meta_title         = 'Welcome to Musik88 API V1'
        @meta_description   = 'Welcome to Musik88 Application Programming Interface V1'
        @meta_url           = request.url
      end

      def root
        render json: {
          code: 200,
          message: 'OK',
          platform: params[:platform],
          tabs_links: tabs_links
        }
      end

      private

      def host
        Rails.env.production? ? 'musik88.com' : 'localhost:3001'
      end

      def tabs_links
        [{
          type: 'home',
          link: "https://#{host}/api/v1/home"
        }, {
          type: 'search',
          link: "https://#{host}/api/v1/search"
        }, {
          type: 'profile',
          link: "https://#{host}/api/v1/profile"
        }]
      end
    end
  end
end
