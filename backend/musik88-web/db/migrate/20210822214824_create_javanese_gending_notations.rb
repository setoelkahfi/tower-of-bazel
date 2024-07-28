class CreateJavaneseGendingNotations < ActiveRecord::Migration[6.0]
  def change
    create_table :javanese_gending_notations do |t|
      t.string :name
      t.text :notation
      t.integer :views_count
      t.boolean :is_published
      t.references :user, foreign_key: true
      t.references :javanese_gending, foreign_key: true

      t.timestamps
    end
  end
end
