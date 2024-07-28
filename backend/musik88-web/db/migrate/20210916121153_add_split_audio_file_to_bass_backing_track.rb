class AddSplitAudioFileToBassBackingTrack < ActiveRecord::Migration[6.1]
  def change
    add_reference :bass_backing_tracks, :split_audio_file, foreign_key: true
  end
end
