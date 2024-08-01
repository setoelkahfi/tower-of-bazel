"use client";

import { useContext, useState } from "react";
import { UserContext } from "../_src/lib/CurrentUserContext";
import { useLogger } from "../_src/lib/logger";
import { CurrentUser, db } from "../_src/lib/db";
import { invoke } from "@tauri-apps/api/tauri";
import { TAURI_ACCOUNT_LOGOUT } from "../_src/lib/tauriHandler";
import { useRouter } from "next/navigation";
import { Button } from "../_ui/components/button";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Page() {
  const [state, setState] = useState(State.LOADING);
  const [user, setUser] = useState<CurrentUser | null>(null);
  const log = useLogger("Logout/Page");
  const router = useRouter();
  const userContext = useContext(UserContext);

  const updateUser = (newUser: CurrentUser | null) => {
    setUser(newUser);
  };

  const logout = async () => {
    try {
      setState(State.LOADING);
      log.debug("user", user);
      log.debug("userContext", userContext);
      const payload = {
        accessToken: userContext.user?.accessToken,
      };
      log.debug("Logging out", payload);
      const res = await invoke(TAURI_ACCOUNT_LOGOUT, payload);
      log.debug(res);
      updateUser(null);
      db.currentUser.clear();
      setState(State.LOADED);
      router.push("/");
      router.refresh();
    } catch (error) {
      log.error(error);
      setState(State.ERROR);
    }
  };

  const buttonText = state === State.LOADING ? "Logging out..." : "Logout";

  return (
    <UserContext.Provider value={{ user, updateUser }}>
      <div className="prose prose-sm prose-invert max-w-none">
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <Button onClick={() => logout()} variant={"outline"} size={"lg"}>
            {buttonText}
          </Button>
          <div>This will remove your session and caches.</div>
        </div>
      </div>
    </UserContext.Provider>
  );
}
