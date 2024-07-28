class AddUserToLyrics < ActiveRecord::Migration[6.0]
  def change
    add_reference :lyrics, :user, foreign_key: true
  end
end
