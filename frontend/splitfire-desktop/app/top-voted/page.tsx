"use client";

import { ContentCarouselResponse } from "@/models/content";
import { invoke } from "@tauri-apps/api";
import { useState, useEffect } from "react";
import { TAURI_CONTENT_TOP_VOTED } from "../_src/lib/tauriHandler";
import { SongProvider } from "../_src/models/SongResponse";
import { SkeletonCard, SongProviderCard, SongProviderPath } from "../_ui/skeleton-card";
import { useLogger } from "../_src/lib/logger";

export default function Page() {
  const log = useLogger("TOp votes");
  const [songProviders, setSongProviders] = useState<SongProvider[]>([]);

  useEffect(() => {
    log.debug("Top votes page loaded");
    async function fetchData() {
      try {
        const response = await invoke<ContentCarouselResponse>(TAURI_CONTENT_TOP_VOTED);
        console.log("Data", response);
        setSongProviders(response.audio_files);
      } catch (error) {
        console.error("Failed to fetch data", error);
      }
    }
    fetchData();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className="space-y-9">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">Top Voted</h1>
        </div>
      </div>
      <div>
        <div className="prose prose-sm prose-invert max-w-none">
          <div className="grid grid-cols-3 gap-6">
            { songProviders.length === 0 && Array.from({ length: 6 }).map((_, i) => (
              <SkeletonCard key={i} isLoading={true} />
            ))}
            { songProviders.length > 0 && songProviders.map((SongProvider, i) => (
              <SongProviderCard key={i} songProvider={SongProvider} path={SongProviderPath.SPLIT} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}