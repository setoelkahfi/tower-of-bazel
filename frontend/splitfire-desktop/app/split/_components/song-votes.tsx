"use client";

import { SongProvider } from "@/models/SongResponse";
import { SongProviderVote } from "@/models/SongVotesDetailResponse";
import VotesView from "./votes-view";
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
      <VotesView
        votes={votes}
        songProviderId={songProvider.id}
        audioFile={songProvider.audio_file}
      />
      <SongVotesImage imagaeUrl={songProvider.image_url} name={songProvider.name} />
    </>
  );
}
