class AddAboutToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :about, :string, default: nil
  end
end