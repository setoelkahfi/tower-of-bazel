import { Logger } from "tslog"

export const useLogger = (name: string) => {
    return new Logger({
        name: name,
        type: 'json',
        minLevel: process.env.NODE_ENV === "production" ?  6: 0,
    })
}