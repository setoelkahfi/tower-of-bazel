"use client";

import YouTube, { Options } from "react-youtube";

export function Video({ providerId }: { providerId: string }) {
  const opts: Options = {
    width: "100%",
    height: "100%",
    playerVars: {
      // https://developers.google.com/youtube/player_parameters
      autoplay: 0,
      mute: 0,
      controls: 0,
      rel: 0,
      showinfo: 0,
    },
  };

  return (
    <div className="mt-2 py-4 aspect-video flex-grow">
      <YouTube videoId={providerId} opts={opts} />
    </div>
  );
}
