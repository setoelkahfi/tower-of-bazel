"use client";

import { useSearchParams } from "next/navigation";
import { useLogger } from "../_src/lib/logger";
import { useEffect } from "react";
import { invoke } from "@tauri-apps/api";
import { TAURI_CONTENT_SONG_BRIDGE_DETAIL } from "../_src/lib/tauriHandler";

export default function Page() {
  const log = useLogger("Play");
  const searchParams = useSearchParams();
  const songProviderId = searchParams.get("songProviderId");

  useEffect(() => {
    log.debug("Play page loaded.");
    async function fetchData() {
      try {
        const rest = await invoke(TAURI_CONTENT_SONG_BRIDGE_DETAIL, { songProviderId });
        log.debug("PreparePlayerResponse", rest);
        
      } catch (error) {
        log.error(error);
      }
    }
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          Splitting file {songProviderId}
      </div>
    </div>
  );
}
