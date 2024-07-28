class AudioFileProcessUpdate < ActiveRecord::Migration[6.1]
  def change
    rename_table :audio_file_splitfire_statuses, :audio_file_split_statuses
    add_column :audio_files, :progress, :integer, default: 0
    remove_column :audio_files, :user_id
  end
end
