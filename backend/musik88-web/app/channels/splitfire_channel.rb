class SplitfireChannel < ApplicationCable::Channel
  def subscribed
    stream_from "SplitfireChannel"
  end

  def unsubscribed
    stop_all_streams
  end
end
