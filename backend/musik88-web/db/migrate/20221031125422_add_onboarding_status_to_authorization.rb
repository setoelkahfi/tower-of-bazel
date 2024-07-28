class AddOnboardingStatusToAuthorization < ActiveRecord::Migration[6.1]
  def change
    add_column :authorizations, :onboarding_status, :integer, default: 0
    add_column :authorizations, :onboarding_status_progress, :boolean, default: 0
  end
end
