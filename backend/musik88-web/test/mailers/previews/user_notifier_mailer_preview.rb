# Preview all emails at http://localhost:3000/rails/mailers/user_notifier_mailer
class UserNotifierMailerPreview < ActionMailer::Preview
  def send_signup_email
    UserNotifierMailer.send_signup_email(User.first)
  end

  def send_reset_password_instructions
    UserNotifierMailer.send_reset_password_instructions(User.first)
  end

  def send_wallet_activation_notification
    UserNotifierMailer.send_wallet_activation_notification(User.first)
  end
end
