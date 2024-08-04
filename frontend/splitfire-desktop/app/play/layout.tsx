"use client";

import React from 'react';

export default function Layout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-9">{children}</div>
  );
}
