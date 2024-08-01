"use client";

import { useContext } from "react";
import { UserContext } from "../_src/lib/CurrentUserContext";
import { useLogger } from "../_src/lib/logger";
import { SkeletonCard } from "../_ui/skeleton-card";
import { usernameOrId } from "../_src/models/user";

export default function Page() {
  const log = useLogger("Profile/Page");
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
      <div className="grid grid-rows-2 grid-flow-row auto-rows-max">
        <div className="max-h-1">
          <h2>@{usernameOrId(user)}</h2>
          <p>{user.name}</p>
        </div>
        <div className="max-w-none">
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <h2 className="text-2xl font-bold">Your plays</h2>
            {Array.from({ length: 6 }).map((_, i) => (
              <SkeletonCard key={i} />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
