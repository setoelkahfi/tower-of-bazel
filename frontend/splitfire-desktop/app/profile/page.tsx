"use client";

import { useContext } from "react";
import { UserContext } from "../_src/lib/CurrentUserContext";
import { useLogger } from "../_src/lib/logger";
import { SkeletonCard } from "../_ui/skeleton-card";
import { usernameOrId } from "../_src/models/user";
import { useSearchParams } from "next/navigation";
import Image from "next/image";

export default function Page() {
  const log = useLogger("Profile/Page");
  const searchParams = useSearchParams();
  const userId = searchParams.get("userId");
  const currentUser = useContext(UserContext);
  log.debug("currentUser");

  const user = currentUser?.user?.user;
  // Sanity check
  if (!user) {
    log.error("No user context");
    return <div>No user context</div>;
  }

  return (
    <div className="prose prose-sm prose-invert max-w-none">
        <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">{user.name}</h1>
        </div>
      </div>
      <div className="grid grid-rows-2 grid-flow-row auto-rows-max">
        <div className="max-h-1">
          <Image src={user.gravatar_url} alt="avatar" width={50} height={50} className="rounded-full"/>
          <h2>@{usernameOrId(user)}</h2>
        </div>
        <div className="max-w-none">
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <h2 className="text-2xl font-bold">Your public plays</h2>
            {Array.from({ length: 6 }).map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
