"use client";

import { useContext, useEffect, useState } from "react";
import { UserContext } from "../_src/lib/CurrentUserContext";
import { useLogger } from "../../lib/logger";
import { usernameOrId } from "../_src/models/user";
import { useSearchParams } from "next/navigation";
import Image from "next/image";
import { invoke } from "@tauri-apps/api";
import { TAURI_ACCOUNT_PROFILE } from "../_src/lib/tauriHandler";
import { AccountProfileResponse } from "@/models/account";
import { TauriResponse } from "@/models/shared";
import { CheckCircleIcon } from "@heroicons/react/outline";

export default function Page() {
  const log = useLogger("Profile/Page");
  const searchParams = useSearchParams();
  const userId = searchParams.get("userId");
  const currentUser = useContext(UserContext);
  const [isOwnProfile, setIsOwnProfile] = useState(false);
  log.debug("currentUser");
  const user = currentUser?.user?.user;

  useEffect(() => {
    log.debug("Profile page loaded.");
    async function fetchData() {
      try {
        const result = await invoke<AccountProfileResponse>(TAURI_ACCOUNT_PROFILE, { userId });
        log.debug("ProfileResponse", result);
        if (result.status === TauriResponse.ERROR) {
          log.error("Error fetching profile");
          return;
        }
        if (!result.user) {
          log.error("No user found");
          return;
        }

        setIsOwnProfile(result.user.id === currentUser?.user?.user.id);
      } catch (error) {
        log.error(error);
      }
    }
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  // Sanity check
  if (!user) {
    log.error("No user context");
    return <div>No user context</div>;
  }

  return (
    <div className="prose prose-sm prose-invert max-w-none grid-rows-3 gap-6">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">{user.name}</h1>
          {(isOwnProfile) && (<CheckCircleIcon className="h-6 w-6 text-green-500" />)}
        </div>
      </div>
      <div className="grid grid-rows-2 grid-flow-row auto-rows-max">
        <div className="max-h-1">
          <Image
            src={user.gravatar_url}
            alt="avatar"
            width={50}
            height={50}
            className="rounded-full"
          />
          <h2>@{usernameOrId(user)}</h2>
        </div>
      </div>
    </div>
  );
}
