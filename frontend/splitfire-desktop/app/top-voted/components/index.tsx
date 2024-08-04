"use client";

import { SkeletonCard } from "@/components/ui/skeleton-card";
import { SongProviderCard, SongProviderPath } from "@/components/ui/song-provider-card";
import { useLogger } from "@/lib/logger";
import { TAURI_CONTENT_TOP_VOTED } from "@/lib/tauri-handler";
import { ContentCarouselResponse } from "@/models/content";
import { SongProvider } from "@/models/song-response";
import { invoke } from "@tauri-apps/api/tauri";
import { useState, useEffect } from "react";

export function Index() {

  const log = useLogger("Top votes");
  const [songProviders, setSongProviders] = useState<SongProvider[]>([]);

  useEffect(() => {
    log.debug("Top votes page loaded");
    async function fetchData() {
      try {
        const response = await invoke<ContentCarouselResponse>(TAURI_CONTENT_TOP_VOTED);
        log.debug("Data", response);
        setSongProviders(response.audio_files);
      } catch (error) {
        log.error("Failed to fetch data", error);
      }
    }
    fetchData();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
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
  );
}