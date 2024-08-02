"use client";

import { SongProvider } from "@/app/_src/models/SongResponse";
import { SongProviderVote } from "@/app/_src/models/SongVotesDetailResponse";
import UpDownVotesView from "./votes-view";
import Image from "next/image";

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
      <Image
        src={songProvider.image_url}
        width={0}
        height={0}
        alt={songProvider.name}
        sizes="100vw"
        className="w-full h-auto aspect-video"
      />
    </>
  );
}
