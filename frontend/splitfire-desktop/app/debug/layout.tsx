"use client";

import React from 'react';

export default async function Layout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-9">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">Debug Settings</h1>
        </div>
      </div>
      <div>{children}</div>
    </div>
  );
}
