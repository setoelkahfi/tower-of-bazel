# frozen_string_literal: true

# Fix this later
# rubocop:disable Metrics/ClassLength
class SessionsController < ApplicationController
  def new
    redirect_to profile_path(current_user.username_or_id) if user_signed_in?

    session[:redirect_after_login_path] = params[:redirect_to] if params[:redirect_to].present?
    session[:omniauth_session_locale] = I18n.locale

    meta_tags('login')
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.valid_password?(params[:session][:password])
      perform_login_if_possible
    else
      flash.now[:danger] = t('invalid_login')
      render 'new'
    end
  end

  def create_pubkey
    pubkey = params[:pubkey]

    # Don't get fancy!
    pubkey_email = "#{pubkey}@musik88.com".downcase

    case params[:postAction]
    when 'createAccount'
      perform_create_account(pubkey_email, pubkey)
      perform_login_pubkey
    when 'checkPubkey'
      perform_check_pubkey(pubkey_email)
    end
  end

  def confirm_email
    return redirect_to login_path if request.get?

    @user = User.find_by_id(params[:id])
    return redirect_to login_path if @user.nil? || @user&.confirmed?

    @user.resend_confirmation_instructions
    # Render confirm_email.js.erb
    @resend_text = t('unconfirmed_email_resend_sent',
                     email: @user.email,
                     email_client_link: email_client_link)
  end

  def destroy
    sign_out if user_signed_in?

    redirect_after_logout_path = params[:redirect_to] ||= root_path
    redirect_to redirect_after_logout_path
  end

  private

  def perform_check_pubkey(pubkey)
    @user = User.find_by(email: pubkey)
    if @user.nil?
      render json: {
        shouldPromptMessageSign: true
      }
    else
      perform_login_pubkey
    end
  end

  def perform_create_account(pubkey_email, pubkey)
    # Create user and return next path
    # Generate name from 3 first and 3 last characters of pubkey
    name = "#{pubkey[0..2]}___#{pubkey[-3..]}"
    @user = User.new(email: pubkey_email, name: name, provider: 'solana', uid: pubkey)
    @user.skip_confirmation!
    @user.skip_password_validation = true
    @user.save
    save_or_update_provider(@user, pubkey)
  end

  def save_or_update_provider(user, pubkey)
    authorization = user.authorizations.find_by(provider: 'solana', uid: pubkey)
    authorization ||= Authorization.new(user_id: user.id, provider: 'solana', uid: pubkey)
    authorization.save
    logger.debug("Authorization: #{authorization}")
  end

  def perform_login_pubkey
    sign_in(:user, @user)
    redirect_to session_redirect

    session.delete(:redirect_after_login_path)
  end

  def session_redirect
    after_login_path = if current_user.need_onboarding?
                         onboarding_path
                       else
                         session[:redirect_after_login_path]
                       end
    after_login_path || profile_path(user.username_or_id)
  end

  def meta_tags(slug)
    meta = Meta
           .select(:title, :description)
           .where(home: slug, locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def perform_login_if_possible
    return render_unconfirmed unless @user.confirmed?

    sign_in(:user, @user)

    create_wallet_if_needed
    sync_spotify_if_needed

    @user.remember_me! if params[:session][:remember_me] == '1'

    redirect_to session_redirect

    session.delete(:redirect_after_login_path)
  end

  def render_unconfirmed
    flash.now[:info] =
      t('unconfirmed_email',
        click_here_link: view_context.link_to(
          t('unconfirmed_email_click_here'),
          confirm_email_path(id: @user.id), method: :post, remote: true
        ),
        email_client_link: email_client_link)
    render 'new'
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
end
