class CreateJavaneseGendings < ActiveRecord::Migration[5.2]
  def change
    create_table :javanese_gendings do |t|
      t.string :name
      t.text :description
      t.text :notation
      t.integer :views_count, default: 0

      t.timestamps
    end
  end
end
