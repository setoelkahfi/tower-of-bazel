class CreateChords < ActiveRecord::Migration[5.2]
  def change
    create_table :chords do |t|
      t.text :chord
      t.integer :song_id, :limit => 8
      t.integer :views_count, :default => 0

      t.timestamps
    end
    add_foreign_key :chords, :songs
  end
end
