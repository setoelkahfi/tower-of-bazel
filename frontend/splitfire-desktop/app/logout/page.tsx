"use client";

import { useContext, useState } from "react";
import { UserContext } from "../../lib/CurrentUserContext";
import { useLogger } from "../../lib/logger";
import { CurrentUser, db } from "../../lib/db";
import { invoke } from "@tauri-apps/api/tauri";
import { TAURI_ACCOUNT_LOGOUT } from "../../lib/tauriHandler";
import { useRouter } from "next/navigation";
import { Button } from "../_ui/components/button";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Page() {
  const [state, setState] = useState(State.LOADED);
  const log = useLogger("Logout/Page");
  const router = useRouter();
  const userContext = useContext(UserContext);

  const logout = async (update: (user: CurrentUser | null) => void) => {
    try {
      setState(State.LOADING);
      log.debug("userContext", userContext);
      const payload = {
        accessToken: userContext.user?.accessToken,
      };
      log.debug("Logging out", payload);
      const res = await invoke(TAURI_ACCOUNT_LOGOUT, payload);
      log.debug(res);
      update(null);
      db.currentUser.clear();
      router.push("/");
    } catch (error) {
      log.error(error);
      setState(State.ERROR);
    }
  };

  const buttonText = state === State.LOADING ? "Logging out..." : "Logout";

  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <UserContext.Consumer>
      {({ updateUser: update }) => (
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          <Button
            onClick={() => logout(update)}
            variant={"outline"}
            size={"lg"}
          >
            {buttonText}
          </Button>
          <div>This will remove your session and caches.</div>
        </div>
      )}
      </UserContext.Consumer>
    </div>
  );
}
