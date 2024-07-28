class CreateGendingNotationVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :gending_notation_votes do |t|
      t.references :user, foreign_key: true
      t.references :javanese_gending_notation, foreign_key: true

      t.timestamps
    end
  end
end
