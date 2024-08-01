"use client";

import { invoke } from "@tauri-apps/api";
import { useEffect, useState } from "react";
import { TAURI_PLAYER_PREPARE } from "../_src/lib/tauriHandler";
import { useSearchParams } from "next/navigation";
import { useLogger } from "../_src/lib/logger";
import { IconSpinner } from "../_ui/components/icons";
import { PlayerPrepareResponse } from "@/models/content";
import { TauriResponse } from "@/models/shared";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Page() {
  const log = useLogger("Play");
  const searchParams = useSearchParams();
  const songProviderId = searchParams.get("songProviderId");
  const [title, setTitle] = useState("Loading song...");
  const [state, setState] = useState(State.LOADING);

  useEffect(() => {
    log.debug("Play page loaded.");
    async function fetchData() {
      try {
        const result: PlayerPrepareResponse = await invoke(
          TAURI_PLAYER_PREPARE,
          { providerId: songProviderId }
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
  }, []);
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
        </div>
      </div>
    </>
  );
}
