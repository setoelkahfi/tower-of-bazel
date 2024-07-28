class AddSizesAndProviderIdToAlbumImage < ActiveRecord::Migration[6.1]
  def change
    add_reference :album_images, :album_provider, foreign_key: true
    add_column :album_images, :height, :integer
    add_column :album_images, :width, :integer
    rename_column :album_images, :source, :provider_type
  end
end
