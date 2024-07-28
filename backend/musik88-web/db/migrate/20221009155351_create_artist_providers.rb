class CreateArtistProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_providers do |t|
      t.references :user, foreign_key: true
      t.string :provider_id
      t.integer :provider_type
      t.string :name
      t.string :genres

      t.timestamps
    end
  end
end
