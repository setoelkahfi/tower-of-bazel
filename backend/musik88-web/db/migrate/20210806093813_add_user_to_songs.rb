class AddUserToSongs < ActiveRecord::Migration[6.0]
  def change
    add_reference :songs, :user, foreign_key: true
  end
end
