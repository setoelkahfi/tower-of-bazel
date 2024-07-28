class AddArtistToArtistProvider < ActiveRecord::Migration[6.1]
  def change
    add_reference :artist_providers, :artist, foreign_key: true
  end
end
