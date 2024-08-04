"use client";

import { Index } from "./components";

export default function Page() {
  return (
    <div className="space-y-9">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">Top Voted</h1>
        </div>
      </div>
      <Index />
    </div>
  );
}