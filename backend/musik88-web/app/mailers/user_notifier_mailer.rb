class UserNotifierMailer < ApplicationMailer
  default from: 'hej@setoelkahfi.se'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: t('user_signup_email_subject')
    )
  end

  def send_reset_password_instructions(user)
    @user = user
    create_reset_password_token(@user)
    mail(
      to: @user.email,
      subject: t('user_send_reset_password_instructions_subject')
    )
  end

  def send_wallet_activation_notification(user)
    @user = user
    @cluster = Rails.env.production? ? '' : '?cluster=devnet'
    @host = Rails.env.production? ? 'musik88.com' : 'localhost:3001'
    mail(
      to: @user.email,
      subject: t('user_send_wallet_activation_notification_subject')
    )
  end

  private

  def create_reset_password_token(user)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    @token = raw
    user.reset_password_token = hashed
    user.reset_password_sent_at = Time.now.utc
    user.save
  end
end
