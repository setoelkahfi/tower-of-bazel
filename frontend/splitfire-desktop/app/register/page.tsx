'use client';

import { invoke } from "@tauri-apps/api";
import { useState } from "react";
import * as Form from "@radix-ui/react-form";
import { TAURI_ACCOUNT_REGISTER } from "../_src/lib/tauriHandler";
import { Button } from "../_ui/components/button";

export default function Page() {

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const register = async () => {
    const payload = {
      name: name,
      email: email,
      password: password,
    };
    console.log("payload", payload);
    const response = await invoke(TAURI_ACCOUNT_REGISTER, payload);
    console.log("response", response);
  };

  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Form.Root className="FormRoot" onSubmit={(event) => { event.preventDefault()}}>
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
              <input className="Input" type="text" value={name}  onChange={(e) => setName(e.currentTarget.value)} required />
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
              <input className="Input" type="email" value={email}  onChange={(e) => setEmail(e.currentTarget.value)} required />
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
              <input className="Input" type="password" value={password} onChange={(e)=>{setPassword(e.currentTarget.value)}} required />
            </Form.Control>
          </Form.Field>
          <Form.Field className="FormField" name="button">
            <Button onClick={register} variant={"outline"} size={"lg"}>Register</Button>
          </Form.Field>
        </Form.Root>
      </div>
    </div>
  );
}