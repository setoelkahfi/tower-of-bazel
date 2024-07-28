import { Link } from "react-router-dom"

export enum Tab {
    Following = 0,
    Followers
}

interface TabMenuProps {
    active: Tab
    usernameOrId: string
}

export default function TabMenu(props: TabMenuProps) {
    return (
        <ul className={'nav nav-tabs nav-justified'}>
            <li className={'nav-item'}>
                <Link 
                    to={`/@${props.usernameOrId}/followers`} 
                    className={`nav-link${props.active === Tab.Followers ? ' active' : ''}`} 
                    aria-current="page">
                Followers
                </Link>
            </li>
            <li className={'nav-item'}>
                <Link 
                    to={`/@${props.usernameOrId}/following`} 
                    className={`nav-link${props.active === Tab.Following ? ' active' : ''}`} 
                    aria-current="page">
                Following
                </Link>
            </li>
        </ul>
    )
}