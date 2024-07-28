class CreateWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :wallets do |t|
      t.references :user, foreign_key: true
      t.string :pubkey
      t.text :seed_phrase

      t.timestamps
    end
  end
end
