class CreateArtistImages < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_images do |t|
      t.references :artist, foreign_key: true
      t.string :url
      t.integer :source

      t.timestamps
    end
  end
end
