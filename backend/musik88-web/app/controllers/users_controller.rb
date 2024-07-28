# frozen_string_literal: true

# Fix this later
# rubocop:disable Metrics/ClassLength
class UsersController < ApplicationController
  def initialize
    @youtube_likes_export_count = 0
    super
  end

  def index
    redirect_to community_path
  end

  def youtube_likes_export_max_iteration
    # If development, set to 2, else 10.
    Rails.env.development? ? 2 : 10
  end

  def community
    @users = User.all.paginate(page: params[:page], per_page: 12)
    @page_title = t('our_community')
    meta_tags('community')
  end

  def show_reputation
    verify_username_or_id

    redirect_to users_path unless @user
  end

  def friends
    verify_username_or_id
    return redirect_to users_path unless @user
  end

  def followers
    redirect_to signup_path if params[:id] == 'sign_up'
    redirect_to login_path if params[:id] == 'sign_in'

    verify_username_or_id

    return redirect_to users_path unless @user

    if !@user.nil? && @user.username == 'splitfire'
      # If it's splitfire page, set cookies to connect to actioncable.
      cookies.permanent.signed[:splitfire_user_id] = @user.id
    end

    meta_tags('profile')
  end

  def following
    redirect_to signup_path if params[:id] == 'sign_up'
    redirect_to login_path if params[:id] == 'sign_in'

    verify_username_or_id

    return redirect_to users_path unless @user

    if !@user.nil? && @user.username == 'splitfire'
      # If it's splitfire page, set cookies to connect to actioncable.
      cookies.permanent.signed[:splitfire_user_id] = @user.id
    end

    meta_tags('profile')
  end

  def show
    redirect_to signup_path if params[:id] == 'sign_up'
    redirect_to login_path if params[:id] == 'sign_in'

    verify_username_or_id
    return redirect_to users_path unless @user

    @show_comment_form = @user.id != current_user&.id
    meta_tags('profile')
  end

  def new
    redirect_to profile_path(current_user.username_or_id) if user_signed_in?

    meta_tags('signup')
    @user = User.new(name: params[:name], email: params[:email])
    @prefilled = params[:email].nil? == false
    @provider = params[:provider]
    @provider_name = @provider == 'spotify' ? 'Spotify' : 'YouTube'

    # Remember locale for omniauth
    session[:omniauth_session_locale] = I18n.locale
  end

  def onboarding
    protect_onboarding_paths

    session[:omniauth_session_locale] = I18n.locale
    @user = current_user
    session[:onboarding_provider] = @user.provider
    meta_tags('onboarding')
  end

  def onboarding_action
    protect_onboarding_paths
    compute_next_step
    render json: { code: 200, next_step: @next_step }
  end

  def username_check
    # Find username
    username = params[:u]

    validate_username username

    render json: {
      'valid': @is_valid,
      'message': @message
    }
  end

  def username
    @username = params[:user][:username].downcase
    current_user.update(username: @username)
    # See username.js.erb
  end

  def onboarding_export_spotify
    return unless user_signed_in?

    SpotifyOnboardingExportJob.perform_now(current_user.id, 'long_term')

    render json: {
      status: 200
    }
  end

  def onboarding_export_youtube
    return unless user_signed_in?

    onboarding_export_youtube_likes
    onboarding_export_youtube_playlists

    render json: { status: 200, message: 'Exported.' }
  end

  def onboarding_export_youtube_likes(page_token = nil)
    @youtube_likes_export_count += 1
    client = YoutubeClient.new(current_user.google)
    response = client.user_likes_videos(page_token)
    response_json = JSON.parse(response.body)

    export_youtube_videos(response_json['items'], current_user.id)

    if response_json['nextPageToken'].present? && @youtube_likes_export_count < youtube_likes_export_max_iteration
      onboarding_export_youtube_likes(response_json['nextPageToken'])
    end
  end

  def onboarding_export_youtube_playlists
    client = YoutubeClient.new(current_user.google)
    client.export_user_playlist
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Redirect to login path with email confirmation instruction message
      flash[:success] = t('welcome_user_unconfirmed')
      redirect_to login_path
    else
      @prefilled = params[:email].nil? == false
      render 'new'
    end
  end

  def settings
    verify_username_or_id
    return redirect_to users_path unless @user

    return redirect_to users_path unless @user == current_user

    if !@user.nil? && @user.username == 'splitfire'
      # If it's splitfire page, set cookies to connect to actioncable.
      cookies.permanent.signed[:splitfire_user_id] = @user.id
    end

    meta_tags('profile')
  end

  def settings_activate_solana
    verify_username_or_id

    return redirect_to users_path unless @user
    return redirect_to users_path unless @user == current_user

    create_wallet_if_needed
    redirect_to settings_path
  end

  def settings_locale
    return render json: { result: 'Not signed in' } unless user_signed_in?
    return render json: { result: 'Locale nil' } unless params[:default_locale]

    user_setting = UserSetting.find_or_create_by(user_id: current_user.id)
    user_setting.update(locale: params[:default_locale].to_i)
    render json: { result: true }
  end

  def update_settings
    return render json: { code: 500, result: 'Error.' } unless update_settings_valid_request?

    user_setting = UserSetting.find_or_create_by(user_id: current_user.id)
    user_setting.update_settings(params[:settings][:type], params[:settings][:value])

    render json: {
      code: 200,
      user_setting: user_setting.as_json
    }
  end

  def update_settings_valid_request?
    verify_username_or_id
    return false unless @user

    return false unless @user == current_user

    true
  end

  # Update from my profile.
  def update
    redirect_to root_path unless user_signed_in?

    if params[:user][:username] != 'seto' && params[:user][:username].length < 5
      flash[:warning] = 'Username minimum 5 characters.'
      redirect_to my_profile_edit_path
      return
    end

    user = User.find_by(id: params[:user][:id])
    # If no information about the provider and uid, update the them.
    user.update(
      name: params[:user][:name],
      username: params[:user][:username],
      instagram: params[:user][:instagram],
      is_private: params[:user][:is_private]
    )

    redirect_to my_profile_path
  end

  def edit; end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private

  def create_wallet_if_needed
    create_wallet_solana
    create_wallet_evm
  end

  def create_wallet_solana
    solana_wallet = Wallet.find_by(user_id: @user.id, wallet_type: Wallet.wallet_types[:solana])
    return unless solana_wallet.nil?

    Wallet.new(user_id: @user.id, wallet_type: Wallet.wallet_types[:solana], status: :pending).save
    WalletSolanaJob.perform_later(@user.id)
  end

  def create_wallet_evm
    evm_wallet = Wallet.find_by(user_id: @user.id, wallet_type: Wallet.wallet_types[:evm])
    return unless evm_wallet.nil?

    Wallet.new(user_id: @user.id, wallet_type: Wallet.wallet_types[:evm], status: :pending).save
    WalletEvmJob.perform_later(@user.id)
  end

  def protect_onboarding_paths
    return redirect_to root_path unless user_signed_in?

    redirect_to root_path unless current_user.need_onboarding?
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def verify_username_or_id
    @user = User.find_by(username: params[:username])
    @user ||= User.find_by_id(params[:username])

    @username_string = "@#{@user&.username_or_id}"
    @username_string += " <i class='bi bi-check-circle-fill'></i>" if @user&.verified?
  end

  def meta_tags(slug)
    meta = Meta
           .select(:title, :description)
           .where(home: slug, locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def validate_username(username)
    @is_valid = false
    if username.length < 4
      @message = t('username_length_invalid')
    elsif !username.ascii_only?
      @message = t('username_character_invalid')
    elsif username !~ /^[[:alnum:]]+$/
      @message = t('username_letters_numbers_only')
    elsif username[0] !~ /[A-Za-z]/
      @message = t('username_should_starts_with_letters')
    elsif User.find_by(username: username.downcase).nil? == false
      @message = t('username_taken')
    else
      @is_valid = true
      @message = t('username_available')
    end
  end

  # Onboarding

  def compute_report_complete
    type = params[:type]
    case type
    # This onboarding types are orderly called from the onboarding page
    when 'username'
      @next_step = 'spotify' if current_user.need_onboarding_spotify?
    when 'spotify'
      current_user.spotify.update(onboarding_status: :onboarded, onboarding_status_progress: 100)
      @next_step = 'google' if current_user.need_onboarding_google?
    when 'google'
      current_user.google.update(onboarding_status: :onboarded, onboarding_status_progress: 100)
    end
  end

  def compute_next_step
    action = params[:onboarding_action]
    @next_step = 'done'
    case action
    # This is get called from the welcome onboarding page to determine the first step
    when 'next'
      # Compute next onboarding step
      if current_user.username.blank?
        @next_step = 'username'
      elsif current_user.need_onboarding_spotify?
        @next_step = 'spotify'
      elsif current_user.need_onboarding_google?
        @next_step = 'google'
      end
    when 'report_complete'
      compute_report_complete
    end
  end

  def export_youtube_videos(items, user_id)
    music_videos = items.select { |item| item['snippet']['categoryId'] == '10' }
    music_videos.each do |video|
      SongProvider.upsert(
        { user_id: user_id, provider_type: :youtube, provider_id: video['id'], name: video['snippet']['title'],
          preview_url: "https://www.youtube.com/watch?v=#{video['id']}", description: video['snippet']['description'],
          image_url: video['snippet']['thumbnails']['high']['url'] },
        unique_by: :index_song_providers_on_provider_id_and_provider_type
      )
    end
  end

  # ENDOF Onboarding
end
