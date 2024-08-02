"use client";

import {
  HTTPStatusCode,
  SongBridgeResponse,
} from "@/app/_src/components/pages/esef/SplitFireView";
import {
  AudioFile,
  Status,
} from "@/app/_src/components/player/models/AudioFile";
import { UserContext } from "@/app/_src/lib/CurrentUserContext";
import { CurrentUser } from "@/app/_src/lib/db";
import { SongProviderVote } from "@/app/_src/models/SongVotesDetailResponse";
import axios from "axios";
import { useRouter } from "next/navigation";
import { CSSProperties, useState, useContext } from "react";
import { Spinner } from "react-bootstrap";
import ButtonGenerateBackingTracks from "./button-split";
import MainVotesView from "./votes-view-main";
import LetsPlayView from "./lets-play";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export enum VoteType {
  UP = "up",
  DOWN = "down",
}

export interface VoteState {
  aggregate: number;
  buttonUpStyle: CSSProperties;
  buttonDownStyle: CSSProperties;
  upVotes: SongProviderVote[];
  downVotes: SongProviderVote[];
}

export default function UpDownVotesView({
  providerId,
  votes,
  audioFile,
}: {
  providerId: string;
  votes: SongProviderVote[];
  audioFile: AudioFile | null;
}) {
  const [state, setState] = useState(State.LOADED);
  const [goToLogin, setGoToLogin] = useState(false);
  const [goToPlayer, setGoToPlayer] = useState(false);
  const { user } = useContext(UserContext);
  const router = useRouter();

  const buttonStyle = (
    votes: SongProviderVote[],
    type: VoteType
  ): CSSProperties => {
    if (!user) {
      return { cursor: "pointer" };
    }

    if (type === VoteType.UP) {
      if (shouldDisableButton(votes, VoteType.UP, user)) {
        return { pointerEvents: "none", opacity: "0.4" };
      } else {
        return { cursor: "pointer" };
      }
    } else {
      if (shouldDisableButton(votes, VoteType.DOWN, user)) {
        return { pointerEvents: "none", opacity: "0.4" };
      } else {
        return { cursor: "pointer" };
      }
    }
  };

  const calculateVotes = (votes: SongProviderVote[]): number => {
    if (votes.length === 0) {
      return 0;
    }

    const up = votes.filter((x) => x.vote_type === VoteType.UP).length;
    const down = votes.filter((x) => x.vote_type === VoteType.DOWN).length;
    //console.log('upvotes', up)
    //console.log('downvotes', down)
    const votesAggregate = up - down;
    return votesAggregate;
  };

  const shouldDisableButton = (
    votes: SongProviderVote[],
    type: VoteType,
    user: CurrentUser
  ) => {
    if (!user) {
      return false;
    }
    const x = votes.filter((y) => {
      if (y.user_id === user.user.id && y.vote_type === type) return true;
      return false;
    });
    return x.length > 0;
  };

  const [voteState, setVoteState] = useState<VoteState>({
    aggregate: calculateVotes(votes),
    buttonUpStyle: buttonStyle(votes, VoteType.UP),
    buttonDownStyle: buttonStyle(votes, VoteType.DOWN),
    upVotes: votes.filter((x) => x.vote_type === VoteType.UP),
    downVotes: votes.filter((x) => x.vote_type === VoteType.DOWN),
  });

  const vote = (type: VoteType) => {
    if (!user || !user.accessToken || user.accessToken.length <= 1) {
      setGoToLogin(true);
      return;
    }

    setState(State.LOADING);
    axios
      .post(
        `/song-bridge/${providerId}/vote`,
        { vote_type: type, provider_id: providerId },
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: user.accessToken,
          },
        }
      )
      .then((res) => {
        const response: SongBridgeResponse = res.data;
        //console.log(response.votes)
        if (response.code === HTTPStatusCode.OK) {
          setVoteState({
            aggregate: calculateVotes(response.votes),
            buttonUpStyle: buttonStyle(response.votes, VoteType.UP),
            buttonDownStyle: buttonStyle(response.votes, VoteType.DOWN),
            upVotes: response.votes.filter((x) => x.vote_type === VoteType.UP),
            downVotes: response.votes.filter(
              (x) => x.vote_type === VoteType.DOWN
            ),
          });
          setState(State.LOADED);
        } else {
          console.log("error");
          setState(State.ERROR);
        }
      })
      .catch((error) => {
        console.log(error);
        setState(State.ERROR);
      });
  };

  const isDoneSplitting = audioFile && audioFile.status === Status.DONE;

  if (goToLogin) {
    router.push("/login");
    return;
  }

  if (goToPlayer) {
    router.push(`/play?audioFileId=${audioFile?.id}`);
    return;
  }

  if (state === State.LOADING) {
    return (
      <div className="mb-3" style={{ minHeight: 250 }}>
        <Spinner animation="border" role="status">
          <span className="visually-hidden">Loading...</span>
        </Spinner>
      </div>
    );
  }

  const mainView = isDoneSplitting ? (
    <LetsPlayView onClick={() => setGoToPlayer(true)} />
  ) : (
    <MainVotesView voteState={voteState} vote={vote} />
  );
  const mainButton = (
    <ButtonGenerateBackingTracks
    providerId={providerId}
    audioFile={audioFile}
    aggregateVotes={voteState.aggregate}
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