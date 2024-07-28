class CreateAlbumArtists < ActiveRecord::Migration[5.2]
  def change
    create_table :album_artists do |t|
      t.boolean :primary
      t.references :album, foreign_key: true
      t.references :artist, foreign_key: true

      t.timestamps
    end
  end
end
