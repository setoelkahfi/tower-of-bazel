"use client";

import { useEffect, useState } from "react";
import { SkeletonCard, SongProviderCard } from "./_ui/skeleton-card";
import { invoke } from "@tauri-apps/api";
import { TAURI_CONTENT_CAROUSEL } from "./_src/lib/tauriHandler";
import { ContentCarouselResponse } from "@/models/content";
import { SongProvider } from "./_src/models/SongResponse";

export default function Page() {

  const [songProviders, setSongProviders] = useState<SongProvider[]>([]);

  useEffect(() => {
    console.log("Discover page loaded");
    async function fetchData() {
      try {
        const response = await invoke<ContentCarouselResponse>(TAURI_CONTENT_CAROUSEL);
        console.log("Data", response);
        setSongProviders(response.audio_files);
      } catch (error) {
        console.error("Failed to fetch data", error);
      }
    }
    fetchData();
  }, []);

  return (
    <div className="space-y-9">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">Discover</h1>
        </div>
      </div>
      <div>
        <div className="prose prose-sm prose-invert max-w-none">
          <div className="grid grid-cols-3 gap-6">
            { songProviders.length === 0 && Array.from({ length: 6 }).map((_, i) => (
              <SkeletonCard key={i} isLoading={true} />
            ))}
            { songProviders.length > 0 && songProviders.map((SongProvider, i) => (
              <SongProviderCard key={i} songProvider={SongProvider} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
