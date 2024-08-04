import { BsArrowUpCircleFill, BsArrowDownCircleFill } from "react-icons/bs";
import { VoterGravatarsViews } from "./voters-view";
import { SongProviderResponse } from "@/models/content";
import { CSSProperties, useContext, useState } from "react";
import { TAURI_CONTENT_SONG_BRIDGE_VOTE } from "@/lib/tauri-handler";
import { TauriResponse } from "@/models/shared";
import { invoke } from "@tauri-apps/api/tauri";
import { UserContext } from "@//lib/current-user-context";
import { useRouter } from "next/navigation";
import { CurrentUser } from "@/lib/db";
import { Spinner } from "react-bootstrap";
import { useLogger } from "@/lib/logger";
import { SongProviderVote } from "@/models/song-votes-detail-response";

export enum VoteType {
  UP = "up",
  DOWN = "down",
}

type VotePayload = {
  songProviderId: number;
  voteType: string;
  accessToken: string;
};

export enum State {
  LOADING,
  LOADED,
  ERROR,
}

export interface VoteState {
  aggregate: number;
  buttonUpStyle: CSSProperties;
  buttonDownStyle: CSSProperties;
  upVotes: SongProviderVote[];
  downVotes: SongProviderVote[];
}

export default function MainVotesView(props: {
  songProviderId: number;
  votes: SongProviderVote[];
  onVotesAggregateUpdate: (votesAggregate: number) => void;
}) {
  const { songProviderId, votes, onVotesAggregateUpdate } = props;

  const log = useLogger("Votes view");
  const router = useRouter();
  const [state, setState] = useState(State.LOADED);
  const [goToLogin, setGoToLogin] = useState(false);
  const { user } = useContext(UserContext);

  const [voteState, setVoteState] = useState<VoteState>({
    aggregate: calculateVotes(votes),
    buttonUpStyle: buttonStyle(votes, VoteType.UP, user),
    buttonDownStyle: buttonStyle(votes, VoteType.DOWN, user),
    upVotes: votes.filter((x) => x.vote_type === VoteType.UP),
    downVotes: votes.filter((x) => x.vote_type === VoteType.DOWN),
  });

  const vote = async (type: VoteType) => {
    if (!user || !user.accessToken || user.accessToken.length <= 1) {
      setGoToLogin(true);
      return;
    }

    setState(State.LOADING);
    try {
      const payload: VotePayload = {
        songProviderId,
        voteType: type,
        accessToken: user.accessToken,
      };
      const response = await invoke<SongProviderResponse>(
        TAURI_CONTENT_SONG_BRIDGE_VOTE,
        payload
      );
      if (response.status === TauriResponse.SUCCESS) {
        setVoteState({
          aggregate: calculateVotes(response.votes),
          buttonUpStyle: buttonStyle(response.votes, VoteType.UP, user),
          buttonDownStyle: buttonStyle(response.votes, VoteType.DOWN, user),
          upVotes: response.votes.filter((x) => x.vote_type === VoteType.UP),
          downVotes: response.votes.filter(
            (x) => x.vote_type === VoteType.DOWN
          ),
        });
        onVotesAggregateUpdate(voteState.aggregate);
        setState(State.LOADED);
      } else {
        log.error("Error voting", response);
        setState(State.ERROR);
      }
    } catch (error) {
      log.error(error);
      setState(State.ERROR);
    }
  };

  if (goToLogin) {
    router.push("/login");
    return <></>;
  }

  return (
    <div className="w-full flex flex-col sm:flex-row flex-wrap sm:flex-nowrap py-4 flex-grow min-h-10">
      <div className="w-fixed w-full flex-shrink flex-grow-0 px-4">
        <VoterGravatarsViews voters={voteState.upVotes} type={VoteType.UP} />
      </div>
      <div className="w-full flex-grow pt-1 px-3 flex justify-center">
        <div className="grid-rows-3 gap-2">
          {state === State.LOADING && (
            <div className="min-h-80">
              <Spinner animation="border" role="status">
              </Spinner>
            </div>
          )}
          {state === State.LOADED && (
            <div>
              <BsArrowUpCircleFill
                size={40}
                className="mb-3"
                style={voteState.buttonUpStyle}
                onClick={() => vote(VoteType.UP)}
                color="green"
              />
              <h1 className="flex justify-center">{voteState.aggregate}</h1>
              <BsArrowDownCircleFill
                size={40}
                className="mt-3"
                style={voteState.buttonDownStyle}
                onClick={() => vote(VoteType.DOWN)}
                color="green"
              />
            </div>
          )}
        </div>
      </div>
      <div className="w-fixed w-full flex-shrink flex-grow-0 px-2">
          <VoterGravatarsViews
            voters={voteState.downVotes}
            type={VoteType.DOWN}
          />
      </div>
    </div>
  );
}

const buttonStyle = (
  votes: SongProviderVote[],
  type: VoteType,
  user: CurrentUser | null
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
