class AddStatusToChord < ActiveRecord::Migration[6.1]
  def change
    add_column :chords, :status, :integer, default: 0
  end
end
