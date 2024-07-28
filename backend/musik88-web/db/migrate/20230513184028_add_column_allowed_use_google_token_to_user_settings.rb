class AddColumnAllowedUseGoogleTokenToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :allowed_use_google_token, :integer, default: 0
  end
end
