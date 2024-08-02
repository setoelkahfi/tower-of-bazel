
import Image from "next/image";

export default function SongVotesImage({
  imagaeUrl: songProviderImageUrl,
  name,
}: {
  imagaeUrl: string | null;
  name: string;
}) {
  if (!songProviderImageUrl) {
    return <div>
      {name}
    </div>;
  }

  return (
    <>
      <Image
        src={songProviderImageUrl}
        width={0}
        height={0}
        alt={name}
        sizes="100vw"
        className="w-full h-auto aspect-video"
      />
    </>
  );
}