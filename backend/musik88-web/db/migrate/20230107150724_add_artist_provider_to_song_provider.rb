class AddArtistProviderToSongProvider < ActiveRecord::Migration[6.1]
  def change
    add_reference :song_providers, :artist_provider, foreign_key: true
  end
end
