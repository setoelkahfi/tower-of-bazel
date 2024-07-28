class AddRefreshTokenToAuthorization < ActiveRecord::Migration[6.1]
  def change
    add_column :authorizations, :refresh_token, :string
    remove_column :authorizations, :token_expires_at, :timestamp
  end
end
