import { Metadata } from 'next';
import React from 'react';

export const metadata: Metadata = {
  title: "Play",
  description: "an intelligent exression engine.",
};


export default async function Layout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-9">
      <div className="flex justify-between">
        <div className="self-start">
          <h1 className="text-3xl font-bold">Login</h1>
        </div>
      </div>
      <div>{children}</div>
    </div>
  );
}
