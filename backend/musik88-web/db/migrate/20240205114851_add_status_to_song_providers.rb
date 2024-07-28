class AddStatusToSongProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :song_providers, :status, :integer, default: 0
  end
end
