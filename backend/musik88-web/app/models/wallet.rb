class Wallet < ApplicationRecord
  belongs_to :user

  enum status: %i[pending done]
  enum wallet_type: %i[evm solana]
end
