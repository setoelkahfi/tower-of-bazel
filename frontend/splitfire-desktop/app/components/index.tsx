"use client";

import { TAURI_CONTENT_CAROUSEL } from "@/lib/tauri-handler";
import { ContentCarouselResponse } from "@/models/content";
import { SongProvider } from "@/models/song-response";
import { invoke } from "@tauri-apps/api";
import { useState, useEffect } from "react";
import {
  SkeletonCard,
  SongProviderCard,
  SongProviderPath,
} from "../_ui/skeleton-card";
import { useLogger } from "@/lib/logger";

export default function Index() {

  const log = useLogger("Discover");
  const [songProviders, setSongProviders] = useState<SongProvider[]>([]);

  useEffect(() => {
    log.debug("Discover page loaded");
    async function fetchData() {
      try {
        const response = await invoke<ContentCarouselResponse>(
          TAURI_CONTENT_CAROUSEL
        );
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
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-3 gap-6">
        {songProviders.length === 0 &&
          Array.from({ length: 6 }).map((_, i) => (
            <SkeletonCard key={i} isLoading={true} />
          ))}
        {songProviders.length > 0 &&
          songProviders.map((SongProvider, i) => (
            <SongProviderCard
              key={i}
              songProvider={SongProvider}
              path={SongProviderPath.SPLIT}
            />
          ))}
      </div>
    </div>
  );
}
