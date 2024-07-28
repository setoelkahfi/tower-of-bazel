class DropImageTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :album_images
    drop_table :artist_images
  end
end
