class AddUserToArtist < ActiveRecord::Migration[6.1]
  def change
    add_reference :artists, :user, foreign_key: true
  end
end
