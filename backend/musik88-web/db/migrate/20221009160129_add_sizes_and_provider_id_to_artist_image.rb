class AddSizesAndProviderIdToArtistImage < ActiveRecord::Migration[6.1]
  def change
    add_reference :artist_images, :artist_provider, foreign_key: true
    add_column :artist_images, :height, :integer
    add_column :artist_images, :width, :integer
    rename_column :artist_images, :source, :provider_type
  end
end
