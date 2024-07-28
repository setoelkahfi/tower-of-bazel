class AddInstagramUsernameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :instagram, :string
  end
end
