import { SongProvider } from "@/models/song-response";
import clsx from "clsx";
import { useRouter } from "next/navigation";
import Image from "next/image";

export enum SongProviderPath {
  PLAY = "play",
  SPLIT = "split",
}

// duplicate skeleton-card.tsx
export function SongProviderCard({
  songProvider,
  path,
}: {
  songProvider: SongProvider;
  path: SongProviderPath;
}) {
  const router = useRouter();
  let queryString = `songProviderId=${songProvider.id}`;
  if (path === SongProviderPath.PLAY && songProvider.audio_file) {
    queryString = `audioFileId=${songProvider.audio_file.id}`;
  }
  const thumbnailView = songProvider.image_url ? (
    <Image
      src={songProvider.image_url}
      alt={songProvider.name}
      width="0"
      height="0"
      sizes="100vw"
      className="w-full h-auto aspect-video"
    />
  ) : (
    <div className="h-14 rounded-lg bg-gray-700" />
  );

  return (
    <button
      className={clsx("rounded-2xl bg-gray-900/80 p-4", {
        "relative overflow-hidden before:absolute before:inset-0 before:-translate-x-full before:animate-[shimmer_1.5s_infinite] before:bg-gradient-to-r before:from-transparent before:via-white/10 before:to-transparent":
          false,
      })}
      onClick={() => router.push(`/${path}?${queryString}`)}
    >
      <div className="space-y-3">
        {thumbnailView}
        <h3 className="w-11/12">{songProvider.name}</h3>
      </div>
    </button>
  );
};
