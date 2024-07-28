class CreateSongChordPleas < ActiveRecord::Migration[5.2]
  def change
    create_table :song_chord_pleas do |t|
      t.references :song, foreign_key: true
      t.references :user, foreign_key: true
    end
  end
end
