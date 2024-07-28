class WalletSolanaJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find_by_id(user_id)
    return unless @user

    change_to_working_directory
    generate_wallet
    setup_bach_token_address
    finish
  end

  private

  def finish
    wallet = Wallet.find_by(user_id: @user.id, wallet_type: Wallet.wallet_types[:solana])
    if wallet.nil?
      system("echo 'Wallet for #{@user.name} does not exist.'")
      return
    end
    wallet.update(pubkey: @pubkey, seed_phrase: @seed_phrase, bach_token_account: @bach_token_account, status: :done)
    wallet.save
  end

  def generate_wallet
    system("echo 'Generating address for #{@user.name}'")

    output        = `solana-keygen new --outfile ./#{@user.id}-keypair.json --no-bip39-passphrase`
    output_array  = output.split("\n")
    @pubkey       = output_array[3].split(' ').last
    @seed_phrase  = output_array[6]

    system("echo 'Wallet is generated for #{@user.name}'")
  end

  def change_to_working_directory
    working_directory_path = if Rails.env.production?
                               '/mnt/HC_Volume_15126575/apps/musik88/solana_wallets/'
                             else
                               '../solana_wallets_devnet/'
                             end
    Dir.chdir(working_directory_path)

    system("echo 'Change working directory to #{working_directory_path}'")
  end

  def setup_bach_token_address
    define_bach_token_id
    setup_solana
    output = `spl-token transfer --fund-recipient --allow-unfunded-recipient #{@bach_token_id} 0.001 #{@pubkey}`
    output_array = output.split("\n")
    @bach_token_account = output_array[3].split(' ').last
  end

  def setup_solana
    if Rails.env.production?
      system('solana config set --keypair ~/.config/solana/main.json')
      system('solana config set --url https://api.mainnet-beta.solana.com')
    else
      system('solana config set --keypair ~/solana-wallets/main.json')
      system('solana config set --url https://api.devnet.solana.com')
    end
  end

  def define_bach_token_id
    @bach_token_id = if Rails.env.production?
                       'CTQBjyrX8pYyqbNa8vAhQfnRXfu9cUxnvrxj5PvbzTmf'
                     else
                       'DENNuKzCcrLhEtxZ8tm7nSeef8qvKgGGrdxX6euNkNS7'
                     end
  end
end
