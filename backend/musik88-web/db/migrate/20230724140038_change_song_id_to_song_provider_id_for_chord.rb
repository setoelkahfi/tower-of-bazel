class ChangeSongIdToSongProviderIdForChord < ActiveRecord::Migration[6.1]
  def change
    remove_reference :chords, :song, index: true, foreign_key: true
    add_reference :chords, :song_provider, index: true, foreign_key: true
  end
end
