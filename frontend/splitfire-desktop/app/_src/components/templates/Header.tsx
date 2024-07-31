import React from 'react'
import { Component } from 'react'
import { Link, Location } from 'react-router-dom'
import 'dexie-observable'
import { usernameOrId } from '../../models/user'
import { Badge, Row } from 'react-bootstrap'
import { UserContext } from '../../lib/CurrentUserContext'

interface HeaderProps {
    location: Location
}

interface HeaderState { }

export default class Header extends Component<HeaderProps, HeaderState> {

    constructor(props: HeaderProps) {
        super(props)
        this.state = {}
    }

    _isActive(path: string): string {
        if (this.props.location.pathname === path)
            return ' active'
        return ''
    }

    render(): React.ReactNode {
        return (
            <UserContext.Consumer>
                {({ user }) => (
                    <header className="mb-5">
                        <Row className="border border-light">
                            <h3 className="float-md-start mb-0">
                                <Link to='/' className={`text-white nav-link${this._isActive('/about')}`} aria-current="page">
                                    <span className=''>SplitFire AI </span>
                                    <Badge bg="warning" text="dark" className='fst-italic fw-light'>beta</Badge>
                                </Link>
                            </h3>
                            <nav className="nav nav-masthead justify-content-center float-md-end mb-3">
                                <Link to='/' className={`nav-link${this._isActive('/')}`} aria-current="page">Home</Link>
                                {
                                    user?.user ? <Link to={`/${usernameOrId(user?.user)}`} className={`nav-link`} aria-current="page">@{usernameOrId(user.user)}</Link>
                                        : <Link to='/login' className={`nav-link${this._isActive('/login')}`} aria-current="page">Login</Link>
                                }
                            </nav>
                        </Row>
                    </header>
                )}
            </UserContext.Consumer>
        )
    }
}