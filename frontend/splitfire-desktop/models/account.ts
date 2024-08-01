import { TauriResponse } from "@/app/_src/lib/tauriHandler";
import User from "@/app/_src/models/user";

export interface AccountLoginResponse {
    status: TauriResponse,
    message: string,
    access_token: string | null,
    user: User | null
}

export interface AccountRegisterResponse {
    status: TauriResponse,
    message: string,
    user: User | null
}