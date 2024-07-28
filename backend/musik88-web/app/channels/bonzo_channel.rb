class BonzoChannel < ApplicationCable::Channel
  def subscribed
    stream_from "BonzoChannel"
  end

  def unsubscribed
    stop_all_streams
  end
end
