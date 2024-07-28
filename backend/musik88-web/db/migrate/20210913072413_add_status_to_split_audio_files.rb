class AddStatusToSplitAudioFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :split_audio_files, :status, :integer, default: 0
  end
end
