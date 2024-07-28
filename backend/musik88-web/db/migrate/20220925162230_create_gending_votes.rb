class CreateGendingVotes < ActiveRecord::Migration[6.1]
  def change
    create_table :gending_votes do |t|
      t.references :user, foreign_key: true
      t.references :javanese_gending, foreign_key: true

      t.timestamps
    end
  end
end
