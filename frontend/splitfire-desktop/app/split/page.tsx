"use client";

import { useSearchParams } from "next/navigation";
import { useLogger } from "@/lib/logger";
import { useEffect, useState } from "react";
import { invoke } from "@tauri-apps/api";
import { TAURI_CONTENT_SONG_BRIDGE_DETAIL } from "@/lib/tauriHandler";
import { SongProvider } from "@/models/SongResponse";
import { SongProviderVote } from "@/models/SongVotesDetailResponse";
import SongVotes from "./_components/song-votes";
import { SongBridgeResponse } from "@/models/content";

export default function Page() {
  const log = useLogger("Play");
  const searchParams = useSearchParams();
  const songProviderId = searchParams.get("songProviderId");
  const [songProvider, setSongProvider] = useState<SongProvider | null>(null);
  const [votes, setVotes] = useState<SongProviderVote[]>([]);

  useEffect(() => {
    log.debug("Play page loaded.");
    async function fetchData() {
      try {
        const rest: SongBridgeResponse = await invoke(
          TAURI_CONTENT_SONG_BRIDGE_DETAIL,
          { songProviderId }
        );
        setSongProvider(rest.song_provider);
        setVotes(rest.votes);
        log.debug("PreparePlayerResponse", rest);
      } catch (error) {
        log.error(error);
      }
    }
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Sanity check
  if (!songProvider) {
    log.error("No songProvider context");
    return <div>No songProvider context</div>;
  }

  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <SongVotes songProvider={songProvider} votes={votes} />
    </div>
  );
}
