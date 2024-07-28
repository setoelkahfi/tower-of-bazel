class AddStatusToWallet < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :status, :integer
  end
end
