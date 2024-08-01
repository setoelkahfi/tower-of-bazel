"use client";

import clsx from "clsx";
import { SongProvider } from "../_src/models/SongResponse";
import Image from "next/image";
import { useRouter } from "next/navigation";

export const SkeletonCard = ({ isLoading }: { isLoading?: boolean }) => (
  <div
    className={clsx("rounded-2xl bg-gray-900/80 p-4", {
      "relative overflow-hidden before:absolute before:inset-0 before:-translate-x-full before:animate-[shimmer_1.5s_infinite] before:bg-gradient-to-r before:from-transparent before:via-white/10 before:to-transparent":
        isLoading,
    })}
  >
    <div className="space-y-3">
      <div className="h-14 rounded-lg bg-gray-700" />
      <div className="h-3 w-11/12 rounded-lg bg-gray-700" />
      <div className="h-3 w-8/12 rounded-lg bg-gray-700" />
    </div>
  </div>
);

// duplicate skeleton-card.tsx
export const SongProviderCard = ({
  songProvider,
}: {
  songProvider: SongProvider;
}) => {
  const router = useRouter();
  return (
    <button
      className={clsx("rounded-2xl bg-gray-900/80 p-4", {
        "relative overflow-hidden before:absolute before:inset-0 before:-translate-x-full before:animate-[shimmer_1.5s_infinite] before:bg-gradient-to-r before:from-transparent before:via-white/10 before:to-transparent":
          false,
      })}
      onClick={() => router.push(`/split?songProviderId=${songProvider.id}`)}
    >
      <div className="space-y-3">
        <Image
          src={songProvider.image_url}
          alt={songProvider.name}
          width="0"
          height="0"
          sizes="100vw"
          className="w-full h-auto aspect-video"
        />
        <h3 className="w-11/12">{songProvider.name}</h3>
      </div>
    </button>
  );
};
