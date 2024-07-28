class CreateKaraokeFileLovers < ActiveRecord::Migration[6.0]
  def change
    create_table :karaoke_file_lovers do |t|
      t.references :karaoke_file, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
