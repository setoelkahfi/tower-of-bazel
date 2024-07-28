class CreateAlbumImages < ActiveRecord::Migration[6.1]
  def change
    create_table :album_images do |t|
      t.references :album, foreign_key: true
      t.string :url
      t.integer :source

      t.timestamps
    end
  end
end
