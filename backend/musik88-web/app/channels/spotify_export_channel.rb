class SpotifyExportChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'SpotifyExportChannel'
  end

  def unsubscribed
    stop_all_streams
  end
end
