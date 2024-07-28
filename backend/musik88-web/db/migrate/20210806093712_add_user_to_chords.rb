class AddUserToChords < ActiveRecord::Migration[6.0]
  def change
    add_reference :chords, :user, foreign_key: true
  end
end
