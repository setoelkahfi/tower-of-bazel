class AddYoutubeVideoIdToAudioFile < ActiveRecord::Migration[6.1]
  def change
    add_column :audio_files, :youtube_video_url, :string, default: nil
    add_column :audio_files, :youtube_video_id, :string, default: nil
  end
end
