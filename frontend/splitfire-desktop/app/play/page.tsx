"use client";

import { invoke } from "@tauri-apps/api";
import { useContext, useEffect, useState } from "react";
import { TAURI_PLAYER_PREPARE } from "../../lib/tauri-handler";
import { useRouter, useSearchParams } from "next/navigation";
import { useLogger } from "../../lib/logger";
import { IconSpinner } from "../_ui/components/icons";
import { PlayerPrepareResponse } from "@/models/content";
import { TauriResponse } from "@/models/shared";
import Player from "./_components/player";
import { UserContext } from "../../lib/current-user-context";

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
  const router = useRouter();

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
  if (!userId) {
    log.error("No user context");
    return router.push("/login");
  }

  if (!audioFileId) {
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
    </>
  );
}
