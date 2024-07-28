module Api
  module V1
    class UserController < Devise::SessionsController
      skip_before_action :verify_authenticity_token
      respond_to :json

      def login
        find_user
        if @user&.valid_password?(params[:password])
          sign_in(:user, @user)
          render_success
        else
          render_error 'Invalid credentials.'
        end
      end

      def logout
        log_out_success && return if current_user

        log_out_failure
      end

      def register
        name      = params[:name]
        email     = params[:email]
        password  = params[:password]

        unless !name.nil? && !name.empty? && !email.nil? && !email.empty? && !password.nil? && !password.empty?
          render_error 'Please fill name, email, and password.'
          return
        end

        @user = User.new(
          name: name,
          email: email,
          password: password
        )

        if @user.save
          # Deliver the signup email.
          UserNotifierMailer.send_signup_email(user).deliver
          render_success
        else
          # Get Devise proper error response.
          render_error 'Something wrong with the registration process. Try again later.'
        end
      end

      def profile
        find_user
        if @user
          render_success
        else
          render_error 'Unknown user.'
        end
      end

      def following
        find_user
        if @user
          render_user_following
        else
          render_error 'Unknown user.'
        end
      end

      def followers
        find_user
        if @user
          render_user_followers
        else
          render_error 'Unknown user.'
        end
      end

      def community
        username_to_exclude = params[:exclude]
        users               = User.all.order(created_at: :asc)
        @filtered_users     = users.reject(username_to_exclude)

        if @filtered_users
          render_community
        else
          render_error 'Unknown error.'
        end
      end

      private

      def find_user
        username = params[:username].downcase
        @user = User.find_by(username: username) || User.find_by(email: username) || User.find_by(id: username)
      end

      def render_success
        render json: {
          code: 200,
          message: 'OK.',
          user: @user.as_json_packed
        }
      end

      def render_error(message)
        render json: {
          code: 500,
          message: message
        }
      end

      def render_user_following
        render json: {
          code: 200,
          message: 'OK.',
          user: @user.as_json_packed,
          following: @user.following.map(&:as_json_packed)
        }
      end

      def render_user_followers
        render json: {
          code: 200,
          message: 'OK.',
          user: @user.as_json_packed,
          followers: @user.followers.map(&:as_json_packed)
        }
      end

      def render_community
        render json: {
          code: 200,
          message: 'OK.',
          users: @filtered_users.map(&:as_json_packed)
        }
      end

      def respond_with(_resource, _opts = {})
        render json: { message: 'You are logged in.' }, status: :ok
      end

      def respond_to_on_destroy
        log_out_success && return if current_user

        log_out_failure
      end

      def log_out_success
        render json: { message: 'You are logged out.' }, status: :ok
      end

      def log_out_failure
        render json: { message: 'Hmm nothing happened.' }, status: :unauthorized
      end
    end
  end
end
