class CreateAudioFileKarokoweStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :audio_file_karokowe_statuses do |t|
      t.references :audio_file, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
