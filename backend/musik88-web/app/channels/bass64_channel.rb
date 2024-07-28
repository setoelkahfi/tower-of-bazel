class Bass64Channel < ApplicationCable::Channel
  def subscribed
    stream_from "Bass64Channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
