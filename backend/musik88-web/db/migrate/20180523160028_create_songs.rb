class CreateSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :songs do |t|
      t.string :name
      t.text :description
      t.string :locale

      t.timestamps
    end
  end
end
