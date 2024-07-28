class AddTitleToChord < ActiveRecord::Migration[6.1]
  def change
    add_column :chords, :title, :string
  end
end
