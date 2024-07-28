class AddTypeToWallets < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :wallet_type, :integer, default: 1
  end
end
