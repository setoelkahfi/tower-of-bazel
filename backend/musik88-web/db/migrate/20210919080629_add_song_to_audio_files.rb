class AddSongToAudioFiles < ActiveRecord::Migration[6.1]
  def change
    add_reference :audio_files, :song, foreign_key: true
  end
end
