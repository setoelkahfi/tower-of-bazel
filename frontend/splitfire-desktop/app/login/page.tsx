"use client";

import * as Form from "@radix-ui/react-form";
import { invoke } from "@tauri-apps/api/tauri";
import { TAURI_ACCOUNT_LOGIN } from "../_src/lib/tauriHandler";
import { Button } from "../_ui/components/button";
import { useState } from "react";
import { UserContext } from "../_src/lib/CurrentUserContext";
import { CurrentUser, CurrentUserType, db } from "../_src/lib/db";
import { AccountLoginResponse } from "@/models/account";
import { Mode } from "../_src/components/player/models/Mode";

export default function Page() {
  const [emailOrUsername, setEmailOrUsername] = useState("");
  const [password, setPassword] = useState("");

  const login = async (update: (user: CurrentUser) => void) => {
    const payload = {
      username: emailOrUsername,
      password: password,
    };
    console.log("payload", payload);
    const response: AccountLoginResponse = await invoke(TAURI_ACCOUNT_LOGIN, payload);
    console.log("response", response);
    let currentUser: CurrentUser = {
      accessToken: "",
      type: CurrentUserType.MAIN,
      user: response.user,
      mode: Mode.Vocal
  }
    db.currentUser.add(currentUser)
    update(currentUser);
  };

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
              <Form.Field className="FormField" name="email">
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
              <Form.Field className="FormField" name="password">
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
              <Form.Field className="FormField" name="password">
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
