class CreateVocalFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :vocal_files do |t|
      t.references :audio_file, index: true, foreign_key: true
      t.timestamps
    end
  end
end
