"use client";

import { AddressBar } from "./_ui/address-bar";
import { GlobalNav } from "./_ui/global-nav";
import "./globals.css";
import { useEffect, useState } from "react";
import { CurrentUser, CurrentUserType, db } from "./_src/lib/db";
import { UserContext } from "./_src/lib/CurrentUserContext";
import { useLogger } from "./_src/lib/logger";

enum State {
  LOADING,
  LOADED,
  ERROR,
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const log = useLogger("App");
  const [state, setState] = useState(State.LOADING);
  const [user, setUser] = useState<CurrentUser | null>(null);

  const updateUser = (newUser: CurrentUser | null) => {
    setUser(newUser);
  };

  const getCurrentUser = async () => {
    setState(State.LOADING);
    try {
      const result = await db.currentUser
        .where({ type: CurrentUserType.MAIN })
        .first();
      log.debug("Result: ", result);
      if (result) {
        setUser(result);
      }
      setState(State.LOADED);
    } catch (error) {
      log.error(error);
      setState(State.ERROR);
    }
  };

  useEffect(() => {
    getCurrentUser();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (state === State.LOADING) {
    return (
      <html lang="en" className="[color-scheme:dark]">
        <body className="bg-gray-1100 overflow-y-scroll bg-[url('/grid.svg')] pb-36">
          Loading app ...
        </body>
      </html>
    );
  }

  if (state === State.ERROR) {
    return (
      <html lang="en" className="[color-scheme:dark]">
        <body className="bg-gray-1100 overflow-y-scroll bg-[url('/grid.svg')] pb-36">
          Error loading app ...
        </body>
      </html>
    );
  }

  return (
    <html lang="en" className="[color-scheme:dark]">
      <body className="bg-gray-1100 overflow-none bg-[url('/grid.svg')] pb-36">
        <UserContext.Provider value={{ user, updateUser }}>
          <GlobalNav />
          <div className="lg:pl-72">
            <div className="fixed top-0 w-full bg-vc-border-gradient rounded-lg p-px shadow-lg shadow-black/20">
              <div className="rounded-lg bg-black">
                <AddressBar />
              </div>
            </div>
            <div className="mx-auto max-w-4xl space-y-8 px-2 mt-10 lg:px-8 lg:py-8">
              <div className="bg-vc-border-gradient rounded-lg p-px shadow-lg shadow-black/20">
                <div className="rounded-lg bg-black p-3.5 lg:p-6">
                  {children}
                </div>
              </div>
            </div>
          </div>
        </UserContext.Provider>
      </body>
    </html>
  );
}
