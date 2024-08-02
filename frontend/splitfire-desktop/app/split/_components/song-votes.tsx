"use client";

import { SongProvider } from "@/app/_src/models/SongResponse";
import { SongProviderVote } from "@/app/_src/models/SongVotesDetailResponse";
import UpDownVotesView from "./votes-view";
import SongVotesImage from "./song-votes-image";

export default function SongVotes({
  songProvider,
  votes,
}: {
  songProvider: SongProvider;
  votes: SongProviderVote[];
}) {
  return (
    <>
      <h1 className="my-2">{songProvider.name}</h1>
      <UpDownVotesView
        votes={votes}
        songProviderId={songProvider.id}
        audioFile={songProvider.audio_file}
      />
      <SongVotesImage imagaeUrl={songProvider.image_url} name={songProvider.name} />
    </>
  );
}
