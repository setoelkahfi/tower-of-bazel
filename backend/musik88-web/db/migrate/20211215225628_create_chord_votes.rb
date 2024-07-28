class CreateChordVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :chord_votes do |t|
      t.references :chord, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
