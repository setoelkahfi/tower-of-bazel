class UpdateAudioFiles < ActiveRecord::Migration[6.1]
  def change
    add_reference :audio_files, :song_provider, index: true
    add_column :audio_files, :status, :integer, default: 0
    remove_reference :audio_files, :song, index: true, foreign_key: true
    remove_column :audio_files, :is_public, :boolean
    remove_column :audio_files, :youtube_video_id, :string
    remove_column :audio_files, :youtube_video_url, :string
  end
end
