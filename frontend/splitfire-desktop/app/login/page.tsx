"use client";

import * as Form from "@radix-ui/react-form";
import { invoke } from "@tauri-apps/api/tauri";
import { TAURI_ACCOUNT_LOGIN } from "@/lib/tauri-handler";
import { useState } from "react";
import { UserContext } from "@/lib/current-user-context";
import { CurrentUser, CurrentUserType, db } from "@/lib/db";
import { AccountLoginResponse } from "@/models/account";
import { useRouter } from "next/navigation";
import { TauriResponse } from "@/models/shared";
import { Mode } from "@/models/mode";
import { LoadingView } from "@/components/ui/loading-view";
import { useLogger } from "@/lib/logger";
import { Button } from "@/components/button";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function Page() {

  const log = useLogger("Login/Page");
  const router = useRouter();
  const [state, setState] = useState(State.LOADED);
  const [emailOrUsername, setEmailOrUsername] = useState("");
  const [password, setPassword] = useState("");
  const [errorMessage, setErrorMessage] = useState("");

  const login = async (update: (user: CurrentUser) => void) => {
    try {
      setState(State.LOADING);
      const payload = {
        username: emailOrUsername,
        password: password,
      };
      log.debug("payload", payload);
      const response: AccountLoginResponse = await invoke(TAURI_ACCOUNT_LOGIN, payload);
      log.debug("response", response);
      if (response.status === TauriResponse.ERROR) {
        console.error("Login failed", response);
        setErrorMessage(response.message);
        return;
      }
      // Sanity check
      if (response.user === null || response.access_token === null) {
        log.error("Login failed", response);
        setErrorMessage(response.message);
        return;
      }

      let currentUser: CurrentUser = {
        accessToken: response.access_token,
        type: CurrentUserType.MAIN,
        user: response.user,
        mode: Mode.Vocal
      }
      db.currentUser.add(currentUser)
      // Update UserContext
      update(currentUser);
      
      router.push("/");
    } catch (error) {
      log.error("Login failed", error);
      setErrorMessage("Login failed. Please try again.");
      setState(State.ERROR);
    }
  };

  if (state === State.LOADING) {
    return <LoadingView />;
  }

  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <UserContext.Consumer>
          {({ user, updateUser: update }) => (
            <Form.Root
              className="FormRoot"
              onSubmit={(event) => {
                event.preventDefault();
              }}
            >
            {state === State.ERROR && (
              <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
                <strong className="font-bold">Error!</strong>
                <span className="block sm:inline">{errorMessage}</span>
                </div>
                )
            }
              <Form.Field className="FormField my-6" name="email">
                <div
                  style={{
                    display: "flex",
                    alignItems: "baseline",
                    justifyContent: "space-between",
                  }}
                >
                  <Form.Label className="FormLabel">Email</Form.Label>
                  <Form.Message className="FormMessage" match="valueMissing">
                    Please enter your email
                  </Form.Message>
                  <Form.Message className="FormMessage" match="typeMismatch">
                    Please provide a valid email
                  </Form.Message>
                </div>
                <Form.Control asChild>
                  <input
                    className="Input"
                    type="email"
                    value={emailOrUsername}
                    onChange={(e) => setEmailOrUsername(e.currentTarget.value)}
                    required
                  />
                </Form.Control>
              </Form.Field>
              <Form.Field className="FormField my-6" name="password">
                <div
                  style={{
                    display: "flex",
                    alignItems: "baseline",
                    justifyContent: "space-between",
                  }}
                >
                  <Form.Label className="FormLabel">Password</Form.Label>
                  <Form.Message className="FormMessage" match="valueMissing">
                    Please enter your email
                  </Form.Message>
                  <Form.Message className="FormMessage" match="typeMismatch">
                    Please provide a valid email
                  </Form.Message>
                </div>
                <Form.Control asChild>
                  <input
                    className="Input"
                    type="password"
                    value={password}
                    onChange={(e) => {
                      setPassword(e.currentTarget.value);
                    }}
                    required
                  />
                </Form.Control>
              </Form.Field>
              <Form.Field className="FormField my-6" name="password">
                <Button onClick={() => login(update)} variant={"outline"} size={"lg"}>
                  Login
                </Button>
              </Form.Field>
            </Form.Root>
          )}
        </UserContext.Consumer>
      </div>
    </div>
  );
}
