import { VoteType } from "@/app/_src/components/pages/song/components/UpDownVotes";
import { SongProviderVote } from "@/app/_src/models/SongVotesDetailResponse";
import Image from "next/image";
import Link from "next/link";

export function VoterGravatarsViews(props: {
  voters: SongProviderVote[];
  type: VoteType;
}) {
  const className =
    props.type === VoteType.DOWN
      ? "justify-end"
      : "justify-start";
  return (
    <div className={className}>
        {props.voters.map((x, i) => {
          return (
            <Link href={`/profile?userId=@${x.user_id}`} key={i}>
              <Image
                src={x.voter_gravatar}
                width={24}
                height={24}
                className="rounded-full"
                alt={x.voter_username_or_id}
              />
            </Link>
          );
        })}
      </div>
  );
}
