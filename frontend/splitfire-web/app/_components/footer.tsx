import Link from "next/link";

export default function Footer() {
  return (
    <div className="mb-32 grid text-center lg:mb-0 lg:w-full lg:max-w-5xl lg:grid-cols-4 lg:text-left">
        <Link href="/just-play" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Just play!
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            No hassle. No waste time.
          </p>
        </Link>

        <Link href="/learn" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Learn!{" "}
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            Learn, practice, repeat! When you&apos;re done, just play!
          </p>
        </Link>

        <Link href="/community" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Community{" "}
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            Play with your friends.
          </p>
        </Link>
        <Link href="/download" className="group rounded-lg border border-transparent px-5 py-4 transition-colors hover:border-gray-300 hover:bg-gray-100 hover:dark:border-neutral-700 hover:dark:bg-neutral-800/30">
          <h2 className="mb-3 text-2xl font-semibold">
            Download desktop app{" "}
            <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
              -&gt;
            </span>
          </h2>
          <p className="m-0 max-w-[30ch] text-sm opacity-50">
            And start playing now!
          </p>
        </Link>
      </div>
  );
}
