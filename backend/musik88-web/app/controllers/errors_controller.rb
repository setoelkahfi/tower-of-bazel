class ErrorsController < ApplicationController
  def not_found
    @meta_title       = 'We are lost'
    @meta_description = 'Sorry, we are lost.'
    render status: 404
  end

  def internal_server_error
    render status: 500
  end
end
