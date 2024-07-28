class CreateBassFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :bass_files do |t|
      t.references :audio_file, index: true, foreign_key: true
      t.timestamps
    end
  end
end
