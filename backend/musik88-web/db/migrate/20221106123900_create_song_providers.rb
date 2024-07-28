class CreateSongProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :song_providers do |t|
      t.references :user, foreign_key: true
      t.references :song, foreign_key: true
      t.string :provider_id
      t.integer :provider_type
      t.string :name
      t.string :preview_url

      t.timestamps
    end
  end
end
