class CreateAudioFileBonzoStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :audio_file_bonzo_statuses do |t|
      t.integer :status
      t.references :audio_file, foreign_key: true

      t.timestamps
    end
  end
end
