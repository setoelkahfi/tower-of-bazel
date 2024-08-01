"use client";

import { useContext, useEffect, useState } from "react";
import { UserContext } from "../_src/lib/CurrentUserContext";
import { useLogger } from "../_src/lib/logger";
import { db } from "../_src/lib/db";
import { invoke } from "@tauri-apps/api/tauri";
import { TAURI_ACCOUNT_LOGOUT } from "../_src/lib/tauriHandler";
import { useRouter } from "next/navigation";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Page() {
  const [state, setState] = useState(State.LOADING);
  const log = useLogger("Logout/Page");
  const currentUser = useContext(UserContext);
  const router = useRouter();

  useEffect(() => {
    async function logout() {
      log.debug(currentUser);
      db.currentUser.clear();
      if (currentUser.user?.accessToken) {
        const res = await invoke(TAURI_ACCOUNT_LOGOUT, {
          accessToken: currentUser.user?.accessToken,
        });
        log.debug(res);
      }
      setState(State.LOADED);
      router.push("/");
    }
    logout();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state]);
  const text = state === State.LOADING ? "Logging out..." : "Logged out";
  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">{text}</div>
    </div>
  );
}
