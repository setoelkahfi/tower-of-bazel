class CreateChordShapes < ActiveRecord::Migration[5.2]
  def change
    create_table :chord_shapes do |t|
      t.string :name
      t.string :youtube_link
      t.string :image_link

      t.timestamps
    end
  end
end
