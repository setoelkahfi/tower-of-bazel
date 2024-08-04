"use client";

import { PARAMS_USER_ID } from '@/lib/params';
import Image from "next/image";
import Link from "next/link";
import { VoteType } from "./votes-view-main";
import { SongProviderVote } from '@/models/song-votes-detail-response';

export function VoterGravatarsViews(props: {
  voters: SongProviderVote[];
  type: VoteType;
}) {
  const className =
    props.type === VoteType.DOWN ? "justify-end" : "justify-start";
  return (
    <div className={className}>
      <div className="flex -space-x-2 overflow-hidden">
        {props.voters.map((x, i) => {
          return (
            <Link href={`/profile?${PARAMS_USER_ID}=${x.user_id}`} key={i}>
              <Image
                src={x.voter_gravatar}
                width={24}
                height={24}
                className="inline-block h-8 w-8 rounded-full ring-2 ring-white"
                alt={x.voter_username_or_id}
              />
            </Link>
          );
        })}
      </div>
    </div>
  );
}
