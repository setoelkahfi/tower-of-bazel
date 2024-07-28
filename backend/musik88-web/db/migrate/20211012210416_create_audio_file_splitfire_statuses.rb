class CreateAudioFileSplitfireStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :audio_file_splitfire_statuses do |t|
      t.references :audio_file, foreign_key: true
      t.integer :status
      t.integer :processing_progress, default: 0

      t.timestamps
    end

    remove_column :audio_files, :status, :integer

    add_column :audio_file_karokowe_statuses, :processing_progress, :integer, default: 0

    add_column :audio_file_bonzo_statuses, :processing_progress, :integer, default: 0

    add_column :audio_file_bass64_statuses, :processing_progress, :integer, default: 0
  end
end
