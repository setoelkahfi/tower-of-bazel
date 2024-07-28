class YoutubeToAudioChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'YoutubeToAudioChannel'
  end

  def unsubscribed
    stop_all_streams
  end
end
