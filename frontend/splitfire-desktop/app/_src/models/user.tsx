export default interface User {
    id: number,
    email: string,
    username: string,
    name: string,
    gravatar_url: string,
    followers_count: number,
    following_count: number,
    about: string,
    access_token: string | null,
}

export function usernameOrId(user: User): string {
    const usernameOrId = user.username ? user.username : `${user.id}`
    return `${usernameOrId}`
}

export interface ProfileResponse {
    code: number,
    message: string,
    user: User
}

export interface FollowingResponse {
    code: number,
    message: string,
    user: User,
    following: User[]
}

export interface FollowersResponse {
    code: number,
    message: string,
    user: User,
    followers: User[]
}