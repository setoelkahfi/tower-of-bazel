class CreateOtherFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :other_files do |t|
      t.references :audio_file, index: true, foreign_key: true
      t.timestamps
    end
  end
end
