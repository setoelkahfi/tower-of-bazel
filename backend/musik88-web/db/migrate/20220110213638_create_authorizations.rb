class CreateAuthorizations < ActiveRecord::Migration[6.1]
  def change
    create_table :authorizations do |t|
      t.references :user, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :token
      t.timestamp :token_expires_at, limit: 6

      t.timestamps
    end
  end
end
