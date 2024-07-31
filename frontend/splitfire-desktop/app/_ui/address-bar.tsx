'use client';

import React from 'react';
import { usePathname } from 'next/navigation';
import { HomeIcon } from '@heroicons/react/solid';

export function AddressBar() {
  const pathname = usePathname();
  console.log('pathname', pathname);
  return (
    <div className="flex items-center gap-x-2 p-3.5 lg:px-5 lg:py-3">
      <div className="text-gray-600">
        <HomeIcon width={16} />
      </div>
      <div className="flex gap-x-1 text-sm font-medium">
        <span className="animate-[highlight_1s_ease-in-out_1] text-gray-100">
          {pathname.replaceAll("/", "").toUpperCase()}
        </span>
      </div>
    </div>
  );
}
