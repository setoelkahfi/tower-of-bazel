class WalletEvmJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find_by_id(user_id)
    return unless @user

    change_to_working_directory
    generate_wallet
    finish
  end

  private

  def change_to_working_directory
    working_directory_path = if Rails.env.production?
                               '/mnt/HC_Volume_15126575/apps/musik88/evm_wallets/'
                             else
                               '../evm_wallets_devnet/'
                             end
    Dir.chdir(working_directory_path)

    system("echo 'Change working directory to #{working_directory_path}'")
  end

  def generate_wallet
    system("echo 'Generating address for #{@user.name}'")

    @filename = "evm_wallet_#{@user.id}.json"
    system("hdwallet generate -s ETH > #{@filename}")

    system("echo 'Wallet is generated for #{@user.name}'")
  end

  def finish
    wallet_information = JSON.parse(File.read(@filename))

    wallet = Wallet.find_by(user_id: @user.id, wallet_type: Wallet.wallet_types[:evm])
    if wallet.nil?
      system("echo 'Wallet for #{@user.name} does not exist.'")
      return
    end
    wallet.update(pubkey: wallet_information['addresses']['p2pkh'], seed_phrase: wallet_information['mnemonic'],
                  status: :done)
    wallet.save
  end
end
