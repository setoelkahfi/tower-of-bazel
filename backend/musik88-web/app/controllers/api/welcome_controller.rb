module Api
  class WelcomeController < ApplicationController
    def index
      @meta_title         = 'Welcome to Musik88 API'
      @meta_description   = 'Welcome to Musik88 Application Programming Interface'
      @meta_url           = request.url
    end
  end
end
