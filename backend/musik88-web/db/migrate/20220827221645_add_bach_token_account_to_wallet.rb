class AddBachTokenAccountToWallet < ActiveRecord::Migration[6.1]
  def change
    add_column :wallets, :bach_token_account, :string
  end
end
