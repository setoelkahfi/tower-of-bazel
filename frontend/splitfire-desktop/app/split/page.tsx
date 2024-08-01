"use client";

import { useSearchParams } from "next/navigation";

export default function Page() {
  const searchParams = useSearchParams();
  const songProviderId = searchParams.get("songProviderId");
  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          Splitting file {songProviderId}
      </div>
    </div>
  );
}
