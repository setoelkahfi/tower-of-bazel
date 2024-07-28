class ChangeColumnName < ActiveRecord::Migration[6.1]
  def self.up
    execute "UPDATE users u SET encrypted_password = u.password_digest FROM users p WHERE u.id = p.id;"
    remove_column :users, :password_digest
  end
end
