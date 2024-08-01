"use client";

import { invoke } from "@tauri-apps/api";
import { useContext, useEffect, useState } from "react";
import { TAURI_PLAYER_PREPARE } from "../_src/lib/tauriHandler";
import { useSearchParams } from "next/navigation";
import { useLogger } from "../_src/lib/logger";
import { IconSpinner } from "../_ui/components/icons";
import { PlayerPrepareResponse } from "@/models/content";
import { TauriResponse } from "@/models/shared";
import Player from "./_components/player";
import { UserContext } from "../_src/lib/CurrentUserContext";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Page() {
  const log = useLogger("Play");
  const searchParams = useSearchParams();
  const audioFileId = searchParams.get("audioFileId");
  const [title, setTitle] = useState("Loading song...");
  const [state, setState] = useState(State.LOADING);
  const user = useContext(UserContext);
  const userId = user.user?.user.id;

  useEffect(() => {
    log.debug("Play page loaded.");
    async function fetchData() {
      try {
        const result: PlayerPrepareResponse = await invoke(
          TAURI_PLAYER_PREPARE,
          { audioFileId }
        );
        log.debug("PreparePlayerResponse", result);
        switch (result.status) {
          case TauriResponse.SUCCESS:
            if (result.audio_file_name) setTitle(result.audio_file_name);

            setState(State.LOADED);
            break;
          case TauriResponse.ERROR:
            setState(State.ERROR);
            break;
        }
      } catch (error) {
        log.error(error);
        setState(State.ERROR);
      }
    }
    fetchData();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
    
  // Sanity check
  if (!audioFileId || !userId) {
    log.error("Missing audio file ID or user ID");
    return <div>Missing audio file ID</div>;
  }
  
  return (
    <>
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">{title}</h1>
        </div>
      </div>
      <div className="prose prose-sm prose-invert max-w-none">
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          {state === State.LOADING && (
            <IconSpinner className="w-10 h-10 animate-spin" />
          )}
          {state === State.ERROR && (
            <div className="text-red-500">Failed to load song</div>
          )}
          {state === State.LOADED && (
            <Player audioId={audioFileId} userId={userId} />
          )}
        </div>
      </div>
    </>
  );
}
