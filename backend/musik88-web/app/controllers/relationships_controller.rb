class RelationshipsController < ApplicationController
  before_action :auth_user

  def auth_user
    redirect_to login_path(redirect_to: request.path) unless user_signed_in?
  end

  def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
    redirect_to profile_path(user.username_or_id)
  end

  def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    redirect_to profile_path(user.username_or_id)
  end
end
