class CreateLyrics < ActiveRecord::Migration[5.2]
  def change
    create_table :lyrics do |t|
      t.text :lyric
      t.string :locale
      t.integer :song_id, :limit => 8

      t.timestamps
    end
    add_foreign_key :lyrics, :songs
  end
end
