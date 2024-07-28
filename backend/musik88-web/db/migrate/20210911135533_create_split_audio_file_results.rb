class CreateSplitAudioFileResults < ActiveRecord::Migration[6.0]
  def change
    create_table :split_audio_file_results do |t|
      t.references :split_audio_file, foreign_key: true

      t.timestamps
    end
  end
end
