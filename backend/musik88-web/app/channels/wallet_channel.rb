class WalletChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'WalletChannel'
  end

  def unsubscribed
    stop_all_streams
  end
end
