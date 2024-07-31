import { Logger } from "tslog"
import isTauri from "./isTauri"

export const useLogger = (name: string) => {
    return new Logger({
        name: name,
        type: isTauri() ? 'json' : 'pretty',
        minLevel: process.env.NODE_ENV === "production" ?  6: 0,
    })
}