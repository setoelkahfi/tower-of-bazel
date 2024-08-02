"use client";

import { ContentCarouselResponse } from "@/models/content";
import { invoke } from "@tauri-apps/api";
import { useEffect, useState } from "react";
import { TAURI_CONTENT_READY_TO_PLAY } from "../_src/lib/tauriHandler";
import { SkeletonCard, SongProviderCard, SongProviderPath } from "../_ui/skeleton-card";
import { SongProvider } from "../_src/models/SongResponse";

export default function Page() {
  const [songProviders, setSongProviders] = useState<SongProvider[]>([]);

  useEffect(() => {
    console.log("Discover page loaded");
    async function fetchData() {
      try {
        const response = await invoke<ContentCarouselResponse>(
          TAURI_CONTENT_READY_TO_PLAY
        );
        console.log("Data", response);
        setSongProviders(response.audio_files);
      } catch (error) {
        console.error("Failed to fetch data", error);
      }
    }
    fetchData();
  }, []);
  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {songProviders.length === 0 &&
          Array.from({ length: 6 }).map((_, i) => (
            <SkeletonCard key={i} isLoading={true} />
          ))}
        {songProviders.length > 0 &&
          songProviders.map((SongProvider, i) => (
            <SongProviderCard key={i} songProvider={SongProvider} path={SongProviderPath.PLAY} />
          ))}
      </div>
    </div>
  );
}