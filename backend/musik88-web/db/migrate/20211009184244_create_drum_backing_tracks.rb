class CreateDrumBackingTracks < ActiveRecord::Migration[6.1]
  def change
    create_table :drum_backing_tracks do |t|
      t.boolean :is_public
      t.references :audio_file, index: true, foreign_key: true

      t.timestamps
    end
  end
end
