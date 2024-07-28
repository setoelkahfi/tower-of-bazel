class CreateLyricSynches < ActiveRecord::Migration[6.1]
  def change
    create_table :lyric_synches do |t|
      t.references :audio_file, foreign_key: true
      t.references :user, foreign_key: true
      t.string :lyric
      t.string :time

      t.timestamps
    end
  end
end
