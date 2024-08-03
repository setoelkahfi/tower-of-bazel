"use client";

import {
  AudioFile,
  Status,
} from "@/app/_src/components/player/models/AudioFile";
import { SongProviderVote } from "@/app/_src/models/SongVotesDetailResponse";
import { useRouter } from "next/navigation";
import { useState } from "react";
import ButtonGenerateBackingTracks from "./button-split";
import MainVotesView, {  } from "./votes-view-main";
import LetsPlayView from "./lets-play";
import { useLogger } from "@/app/_src/lib/logger";

export default function VotesView({
  songProviderId,
  votes,
  audioFile,
}: {
  songProviderId: number;
  votes: SongProviderVote[];
  audioFile: AudioFile | null;
}) {

  const log = useLogger("Votes view");
  const [goToPlayer, setGoToPlayer] = useState(false);
  const router = useRouter();
  const [votesAggregate, setVotesAggregate] = useState(0);

  const isDoneSplitting = audioFile && audioFile.status === Status.DONE;

  if (goToPlayer) {
    log.debug("Go to player");
    router.push(`/play?audioFileId=${audioFile?.id}`);
    return;
  }

  const onVotesAggregateUpdate = (votesAggregate: number) => {
    setVotesAggregate(votesAggregate);
  }

  const mainView = isDoneSplitting ? (
    <LetsPlayView onClick={() => setGoToPlayer(true)} />
  ) : (
    <MainVotesView songProviderId={songProviderId} votes={votes} onVotesAggregateUpdate={onVotesAggregateUpdate} />
  );
  const mainButton = (
    <ButtonGenerateBackingTracks
      songProviderId={songProviderId}
      audioFile={audioFile}
      aggregateVotes={votesAggregate}
    />
  );
  // Votes treshold is passed, show the generate button.
  return (
    <div className="grid-rows-2">
      <div className="flex justify-center">
        {mainButton}
      </div>
      <div className="flex justify-center min-h-8">
        {mainView}
      </div>
    </div>
  );
}
