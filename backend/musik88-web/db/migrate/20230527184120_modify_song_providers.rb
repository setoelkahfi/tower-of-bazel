class ModifySongProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :song_providers, :description, :string
    add_column :song_providers, :image_url, :string
    change_column :song_providers, :created_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    change_column :song_providers, :updated_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    remove_column :song_providers, :album_provider_id
    remove_column :song_providers, :artist_provider_id
    add_index :song_providers, %i[provider_id provider_type], unique: true
  end
end
