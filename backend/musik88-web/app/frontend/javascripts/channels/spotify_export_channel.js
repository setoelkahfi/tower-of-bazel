import consumer from "./consumer"

consumer.subscriptions.create(
  { channel: "SpotifyExportChannel" },
  {
    connect() {},
    received(data) {
      console.log("Received data.", data)
    }
  }
)