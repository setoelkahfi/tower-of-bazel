class CreateChordHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :chord_histories do |t|
      t.references :chord, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
