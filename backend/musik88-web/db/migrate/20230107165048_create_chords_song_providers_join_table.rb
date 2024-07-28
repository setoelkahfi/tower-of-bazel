class CreateChordsSongProvidersJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :chords, :song_providers do |t|
      t.index :chord_id
      t.index :song_provider_id
    end
  end
end
