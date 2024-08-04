"use client";

import { useLogger } from "@/lib/logger";
import { useState } from "react";
import { State, SignupForm, SignupState } from "./signup-form";
import SignupSuccess from "./signup-success";

export function Index() {
  const log = useLogger("Register/Page");
  const [state, setState] = useState(State.LOADED);

  const registerCallback = (state: SignupState) => {
    log.debug("Register callback", state);
    if (state === SignupState.SUCCESS) {
      setState(State.SUCCESS);
    } else {
      setState(State.ERROR);
    }
  }
  const view = state === State.SUCCESS ? <SignupSuccess /> : <SignupForm registerCallback={registerCallback} />;
  
  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {view}
      </div>
    </div>
  );
}