class RenameColumnAndIndexes < ActiveRecord::Migration[6.1]
  def change
    rename_column :splitfire_results, :split_audio_file_id, :audio_file_id
    rename_column :audio_file_bass64_statuses, :split_audio_file_id, :audio_file_id
    rename_column :bass_backing_tracks, :split_audio_file_id, :audio_file_id
  end
end
