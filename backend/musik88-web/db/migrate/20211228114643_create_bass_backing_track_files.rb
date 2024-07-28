class CreateBassBackingTrackFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :bass_backing_track_files do |t|
      t.references :audio_file, foreign_key: true
      t.integer :status, default: 0
      t.integer :status_progress, default: 0
      t.integer :views_count

      t.timestamps
    end
  end
end
