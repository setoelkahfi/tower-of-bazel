class CreateAudioFileBass64Statuses < ActiveRecord::Migration[6.1]
  def change
    create_table :audio_file_bass64_statuses do |t|
      t.references :split_audio_file, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
