import User from "@/app/_src/models/user";
import { TauriResponse } from "./shared";

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

export interface AccountProfileResponse {
    status: TauriResponse,
    message: string,
    user: User | null
}
