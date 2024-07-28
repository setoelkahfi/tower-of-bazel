class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale, :remove_splitfire_user_id

  protected

  def access_denied(exception)
    flash[:danger] = exception.message
    redirect_to root_path
  end

  def authenticate_admin!
    redirect_to new_user_session_path unless current_user.admin?
  end

  def remove_splitfire_user_id
    cookies.delete(:splitfire_user_id)
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
