"use client";

import { invoke } from "@tauri-apps/api";
import { useState } from "react";
import * as Form from "@radix-ui/react-form";
import { TAURI_ACCOUNT_REGISTER, TauriResponse } from "../_src/lib/tauriHandler";
import { Button } from "../_ui/components/button";
import { useLogger } from "../_src/lib/logger";
import { AccountRegisterResponse } from "@/models/account";

enum State {
  LOADING,
  LOADED,
  ERROR,
  SUCCESS
}

enum SignupState {
  ERROR,
  SUCCESS
}

type SignupFormPayload = {
  name: string,
  email: string,
  password: string
}

export default function Page() {
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

function SignupSuccess() {
  return (
    <div>
      <h1>Success</h1>
      <p>Your account has been created successfully.</p>
      <p>Check your email to confirm your account.</p>
    </div>
  );
}

function SignupForm({ registerCallback }: { registerCallback: (state: SignupState) => void }) {
  const log = useLogger("Register/Form");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [state, setState] = useState(State.LOADED);

  const register = async () => {
    setState(State.LOADING);
    try {
      const payload: SignupFormPayload = {
        name,
        email,
        password
      };
      log.debug("payload", payload);
      const response = await invoke<AccountRegisterResponse>(TAURI_ACCOUNT_REGISTER, payload);
      log.debug("response", response);
      if (response.status === TauriResponse.ERROR) {
        log.error("Register failed", response);
        setState(State.ERROR);
        return;
      }
      setState(State.SUCCESS);
      // Call the callback to update the parent state
      registerCallback(SignupState.SUCCESS);
    } catch (error) {
      log.error("Register failed", error);
      setState(State.ERROR);
    }
  };

  const buttonText = state === State.LOADING ? "Registering..." : "Register";

  return (
    <Form.Root
    className="FormRoot"
    onSubmit={(event) => {
      event.preventDefault();
    }}
  >
    <Form.Field className="FormField" name="name">
      <div
        style={{
          display: "flex",
          alignItems: "baseline",
          justifyContent: "space-between",
        }}
      >
        <Form.Label className="FormLabel">Name</Form.Label>
        <Form.Message className="FormMessage" match="valueMissing">
          Please enter your name
        </Form.Message>
        <Form.Message className="FormMessage" match="typeMismatch">
          Please provide a valid name
        </Form.Message>
      </div>
      <Form.Control asChild>
        <input
          className="Input"
          type="text"
          value={name}
          onChange={(e) => setName(e.currentTarget.value)}
          required
        />
      </Form.Control>
    </Form.Field>
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
          value={email}
          onChange={(e) => setEmail(e.currentTarget.value)}
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
    <Form.Field className="FormField" name="button">
      <Button onClick={register} variant={"outline"} size={"lg"}>
        {buttonText}
      </Button>
    </Form.Field>
  </Form.Root>
  )
}