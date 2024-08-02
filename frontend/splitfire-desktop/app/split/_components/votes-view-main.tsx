import { BsArrowUpCircleFill, BsArrowDownCircleFill } from "react-icons/bs";
import { VoteState, VoteType } from "./votes-view";
import { VoterGravatarsViews } from "./voters-view";

export default function MainVotesView(props: {
  voteState: VoteState;
  vote: (type: VoteType) => void;
}) {
  const { voteState, vote } = props;

  return (
    <div className="w-full flex flex-col sm:flex-row flex-wrap sm:flex-nowrap py-4 flex-grow">
      <div className="w-fixed w-full flex-shrink flex-grow-0 px-4 ">
        <VoterGravatarsViews voters={voteState.upVotes} type={VoteType.UP} />
      </div>
      <div className="w-full flex-grow pt-1 px-3 flex justify-center">
        <div className="grid-rows-3 gap-2">
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
