class AddSynchSpotifyToUserSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :user_settings, :sync_spotify, :integer, default: 1
  end
end
