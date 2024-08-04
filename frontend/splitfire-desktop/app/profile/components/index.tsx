"use client";

import { useContext, useEffect, useState } from "react";
import { useLogger } from "@/lib/logger";
import User, { usernameOrId } from "@/models/user";
import { useSearchParams } from "next/navigation";
import Image from "next/image";
import { invoke } from "@tauri-apps/api";
import { TAURI_ACCOUNT_PROFILE } from "@/lib/tauri-handler";
import { AccountProfileResponse } from "@/models/account";
import { TauriResponse } from "@/models/shared";
import { LocationMarkerIcon } from "@heroicons/react/solid";
import { GearIcon } from "@radix-ui/react-icons";
import Link from "next/link";
import { PARAMS_USER_ID } from "@/_lib/params";
import { UserContext } from "@/lib/current-user-context";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Index() {
  const log = useLogger("Profile/Page");
  const searchParams = useSearchParams();
  const userId = searchParams.get(PARAMS_USER_ID);
  const [isOwnProfile, setIsOwnProfile] = useState(false);
  const [userDisplayed, setUserDisplayed] = useState<User | null>(null);
  const [state, setState] = useState(State.LOADING);
  const userContext = useContext(UserContext);
  const loggedInUser = userContext.user?.user;

  useEffect(() => {
    log.debug("Profile page loaded.");
    async function fetchData() {
      try {
        const result = await invoke<AccountProfileResponse>(
          TAURI_ACCOUNT_PROFILE,
          { userId }
        );
        log.debug("ProfileResponse", result);
        if (result.status === TauriResponse.ERROR) {
          log.error("Error fetching profile");
          return;
        }
        if (!result.user) {
          log.error("No user found");
          setState(State.ERROR);
          return;
        }

        setIsOwnProfile(result.user.id === loggedInUser?.id);
        setUserDisplayed(result.user);
        setState(State.LOADED);
      } catch (error) {
        log.error(error);
        setState(State.ERROR);
      }
    }
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (state === State.LOADING) {
    return (
      <div className="prose prose-sm prose-invert max-w-none grid-rows-3 gap-6">
        Loading...
      </div>
    );
  }

  if (state === State.ERROR) {
    return (
      <div className="prose prose-sm prose-invert max-w-none grid-rows-3 gap-6">
        Error loading profile
      </div>
    );
  }

  if (!userDisplayed) {
    return (
      <div className="prose prose-sm prose-invert max-w-none grid-rows-3 gap-6">
        User not found
      </div>
    );
  }

  return (
    <div className="w-full px-4 mx-auto">
      <div className="relative flex flex-col min-w-0 break-words mb-6 shadow-xl rounded-lg mt-16">
        <div className="px-6">
          <div className="flex flex-wrap justify-center">
            <div className="w-full px-4 flex justify-center">
              <div className="">
                <Image
                  src={userDisplayed.gravatar_url}
                  width={150}
                  height={150}
                  className="shadow-xl rounded-full h-auto align-middle border-none absolute -m-16 -ml-20 max-w-150-px"
                  alt={userDisplayed.name}
                />
              </div>
            </div>
            <div className="w-full px-4 text-center mt-20">
              <div className="flex justify-center py-4 lg:pt-4 pt-8">
                <div className="mr-4 p-3 text-center">
                  <span className="text-xl font-bold block uppercase tracking-wide text-blueGray-600">
                    {userDisplayed.followers_count}
                  </span>
                  <span className="text-sm text-blueGray-400">Followers</span>
                </div>
                <div className="lg:mr-4 p-3 text-center">
                  <span className="text-xl font-bold block uppercase tracking-wide text-blueGray-600">
                    {userDisplayed.following_count}
                  </span>
                  <span className="text-sm text-blueGray-400">Following</span>
                </div>
              </div>
            </div>
          </div>
          <div className="text-center mt-12">
            <h3 className="text-xl font-semibold leading-normal text-blueGray-700 mb-2">
              {userDisplayed.name}{" "}
              <span className="text-blueGray-400 font-normal">
                (@{usernameOrId(userDisplayed)})
              </span>
            </h3>
            {isOwnProfile && (
              <div className="absolute -m-4 -mr-4">
                <Link href="/profile/update">
                  <GearIcon className="h-6 w-6 text-blueGray-300" />
                </Link>
              </div>
            )}
            <div className="text-sm leading-normal mt-0 mb-2 text-blueGray-400 font-bold uppercase">
              <LocationMarkerIcon className="h-4 w-4 inline-block" /> Stockholm
            </div>
          </div>
          <div className="mt-10 py-10 border-t border-blueGray-200 text-center">
            <div className="flex flex-wrap justify-center">
              <div className="w-full lg:w-9/12 px-4">
                <p className="mb-4 text-lg leading-relaxed text-blueGray-700">
                  {userDisplayed.about}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
