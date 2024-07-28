class KarokoweChannel < ApplicationCable::Channel
  def subscribed
    stream_from "KarokoweChannel"
  end

  def unsubscribed
    stop_all_streams
  end
end
