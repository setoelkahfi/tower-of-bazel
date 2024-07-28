class AddIsPublicToAudioFile < ActiveRecord::Migration[6.1]
  def change
    add_column :audio_files, :is_public, :boolean, default: false
  end
end
