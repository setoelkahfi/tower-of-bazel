class RenameSplitAudioFilesToAudioFiles < ActiveRecord::Migration[6.1]
  def change
    rename_table :split_audio_files, :audio_files
    rename_table :split_audio_file_results, :splitfire_results
  end
end
