class AddColumnAllowedUseSpotifyTokenToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :allowed_use_spotify_token, :integer, default: 0
  end
end
