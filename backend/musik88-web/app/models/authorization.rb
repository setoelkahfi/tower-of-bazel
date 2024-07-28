class Authorization < ApplicationRecord
  belongs_to :user

  enum onboarding_status: [
    :pending,             # Not onboarding.
    :onboarding,          # In progress.
    :onboarded            # Done.
  ]

  def update_token(token, refresh_token)
    update(token: token)
    update(refresh_token: refresh_token)
  end
end
