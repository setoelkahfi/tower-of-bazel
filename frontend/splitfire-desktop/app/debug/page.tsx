"use client";

import * as Form from "@radix-ui/react-form";
import { invoke } from "@tauri-apps/api/tauri";
import {
  TAURI_GET_ENVIRONMENT,
  TAURI_SET_ENVIRONMENT,
} from "@/lib/tauri-handler";
import { useEffect, useState } from "react";
import { TauriResponse } from "@/models/shared";
import { useLogger } from "@/lib/logger";
import { LoadingView } from "@/components/ui/loading-view";
import { Button } from "@/components/button";

enum State {
  LOADING,
  LOADED,
  ERROR,
}
enum Environment {
  DEVELOPMENT = "development",
  PRODUCTION = "production",
}

interface UpdateSettingsResponse {
  status: TauriResponse;
}

export default function Page() {
  const log = useLogger("Debug settings");
  const [state, setState] = useState(State.LOADED);
  const [environment, setEnvironment] = useState<Environment>(
    Environment.PRODUCTION
  );

  const updateEnvironment = async () => {
    try {
      setState(State.LOADING);
      const payload = { environment };
      log.debug("payload", payload);
      const response: UpdateSettingsResponse = await invoke(
        TAURI_SET_ENVIRONMENT,
        payload
      );
      log.debug("response", response);
      setState(State.LOADED);
    } catch (error) {
      log.error("Error updating environment", error);
      setState(State.ERROR);
    }
  };

  const onSelectedEnvironmentChange = (value: string) => {
    log.debug("Selected environment", value);
    setEnvironment(value as Environment);
  };

  useEffect(() => {
    log.debug("Debug settings page loaded.");
    async function fetchData() {
      try {
        const environment: Environment = await invoke(TAURI_GET_ENVIRONMENT);
        log.debug("Current environment settings", environment);
        setEnvironment(environment);
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
    return <LoadingView />;
  }

  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="flex grid-rows-1">
        <Form.Root
          className="FormRoot"
          onSubmit={(event) => {
            event.preventDefault();
          }}
        >
          <Form.Field className="FormField my-6" name="Environment">
            <div
              style={{
                display: "flex",
                alignItems: "baseline",
                justifyContent: "space-between",
              }}
            >
              <Form.Label className="FormLabel">Environment</Form.Label>
            </div>
            <Form.Control asChild className="my-6">
              <select
                onChange={(e) =>
                  onSelectedEnvironmentChange(e.currentTarget.value)
                }
              >
                <option
                  value={Environment.DEVELOPMENT}
                  selected={environment === Environment.DEVELOPMENT}
                >
                  Development
                </option>
                <option
                  value={Environment.PRODUCTION}
                  selected={environment === Environment.PRODUCTION}
                >
                  Production
                </option>
              </select>
            </Form.Control>
          </Form.Field>
          <Form.Field className="FormField my-6" name="password">
            <Button onClick={updateEnvironment} variant={"outline"} size={"lg"}>
              Update
            </Button>
          </Form.Field>
        </Form.Root>
      </div>
    </div>
  );
}
