import { createContext } from "react";
import { CurrentUser } from "./db";

interface CurrentUserContext {
    user: CurrentUser | null
    updateUser: (user: CurrentUser) => void
}

export const UserContext = createContext<CurrentUserContext>({ user: null, updateUser: () => { } });