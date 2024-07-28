# frozen_string_literal: true

# Fix this later
# rubocop:disable Metrics/ClassLength
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Apple call the callback as a POST request. Just Apple being Apple.
    skip_before_action :verify_authenticity_token, only: [:apple]
    before_action :set_locale

    def facebook
      # TODO: Onboarding from Facebook
      @user = User.from_omniauth(request.env['omniauth.auth'])
      try_login
    end

    def spotify
      auth = request.env['omniauth.auth']
      # Check if this is a pubkey auth onboarding by checking onboarding_provider session
      return web3_setup_onboarding_provider(auth) if session[:onboarding_provider] == 'solana'

      @user = User.find_by(email: auth.info.email)
      try_login_or_signup(auth)
    end

    def google_oauth2
      auth = request.env['omniauth.auth']
      # Check if this is a pubkey auth onboarding by checking onboarding_provider session
      return web3_setup_onboarding_provider(auth) if session[:onboarding_provider] == 'solana'

      @user = User.find_by(email: auth.info.email)
      try_login_or_signup(auth)
    end

    def apple
      # TODO: Onboarding from Apple
      @user = User.from_omniauth(request.env['omniauth.auth'])
      try_login
    end

    def failure
      redirect_to root_path
    end

    # Setup locale from the previous omniauth call
    def set_locale
      I18n.locale = session[:omniauth_session_locale]
    end

    private

    def web3_setup_onboarding_provider(auth)
      # We should have a current_user here that is pubkey authenticated
      return redirect_to login_path if current_user.nil?

      logger.info "web3_setup_spotify_provider: #{current_user}"
      @user = current_user
      User.from_omniauth_web3(auth, current_user.email)
      onboarding(nil)
    end

    def try_login_or_signup(auth)
      return signup(auth) if @user.nil?

      User.from_omniauth(auth)
      try_login
    end

    def try_login
      return handle_unconfirmed_email unless @user.confirmed?

      return redirect_to login_path unless @user.persisted?

      ab_finished(:only_spotify_youtube, reset: true)

      sign_in @user
      create_wallet_if_needed
      sync_spotify_if_needed

      flash[:success] = t('welcome_user', user_name: @user.name) unless current_user.need_onboarding?
      redirect_to session_redirect
    end

    def handle_unconfirmed_email
      flash[:info] =
        t('unconfirmed_email',
          click_here_link: view_context.link_to(
            t('unconfirmed_email_click_here'),
            confirm_email_path(id: @user.id), method: :post, remote: true
          ),
          email_client_link: email_client_link)
      redirect_to login_path
    end

    def email_client_link
      view_context.link_to(
        t('unconfirmed_email_email_app'),
        "https://#{@user.email_client}",
        target: '__blank'
      )
    end

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

    def sync_spotify_if_needed
      return if current_user.need_onboarding?

      return unless @user.user_setting.sync_spotify?

      SpotifyOnboardingExportJob.perform_later(@user.id, 'short_term')
      SpotifySyncExportJob.perform_later(@user.id)
    end

    def session_redirect
      # Override redirection if needed
      redirect_after_login_path = if current_user.need_onboarding?
                                    onboarding_path
                                  else
                                    session[:redirect_after_login_path]
                                  end
      redirect_after_login_path || profile_path(current_user.username_or_id)
    end

    def delete_session
      session.delete(:redirect_after_login_path)
      session.delete(:omniauth_session_locale)
    end

    def signup(auth)
      redirect_to signup_path(provider: auth.provider, email: auth.info.email, name: auth.info.name,
                              uid: auth.uid, token: auth.credentials.token)
    end

    def onboarding(auth)
      return redirect_to onboarding_path if auth.nil?

      redirect_to onboarding_path(provider: auth.provider, email: auth.info.email, name: auth.info.name,
                                  uid: auth.uid, token: auth.credentials.token)
    end
  end
end
