class AddSongProviderAndArtistProviderToSongArtist < ActiveRecord::Migration[6.1]
  def change
    add_reference :song_artists, :song_provider, foreign_key: true
    add_reference :song_artists, :artist_provider, foreign_key: true
  end
end
