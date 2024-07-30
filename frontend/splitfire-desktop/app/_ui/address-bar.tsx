'use client';

import React, { Suspense } from 'react';
import { usePathname, useSearchParams } from 'next/navigation';
import { HomeIcon } from '@heroicons/react/solid';

function Params() {
  const searchParams = useSearchParams()!;

  return searchParams.toString().length !== 0 ? (
    <div className="px-2 text-gray-500">
      <span>?</span>
      {Array.from(searchParams.entries()).map(([key, value], index) => {
        return (
          <React.Fragment key={key}>
            {index !== 0 ? <span>&</span> : null}
            <span className="px-1">
              <span
                key={key}
                className="animate-[highlight_1s_ease-in-out_1] text-gray-100"
              >
                {key}
              </span>
              <span>=</span>
              <span
                key={value}
                className="animate-[highlight_1s_ease-in-out_1] text-gray-100"
              >
                {value}
              </span>
            </span>
          </React.Fragment>
        );
      })}
    </div>
  ) : null;
}

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
