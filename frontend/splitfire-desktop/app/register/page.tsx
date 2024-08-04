"use client";

import { Index } from "./components";

export default function Page() {
  return (
    <div className="prose prose-sm prose-invert max-w-none">
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        <Index />
      </div>
    </div>
  );
}