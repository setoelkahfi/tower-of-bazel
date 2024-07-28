class CreateLyricVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :lyric_votes do |t|
      t.references :lyric, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
