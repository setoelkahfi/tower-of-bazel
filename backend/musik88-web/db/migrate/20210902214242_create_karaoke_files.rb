class CreateKaraokeFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :karaoke_files do |t|
      t.string :link
      t.references :song, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
