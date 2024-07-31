import { useContext, useEffect } from "react"
import { Spinner } from "react-bootstrap"
import axios from "../../lib/axios"
import { UserContext } from "../../lib/CurrentUserContext"

interface LogoutProps {
    didLogout: () => void
}

export default function Logout(props: LogoutProps) {

    const currentUser = useContext(UserContext)

    useEffect(() => {
        console.log(currentUser)
        if (currentUser.user?.accessToken) {
            axios
                .delete(`/logout`, {
                    headers: {
                        'Authorization': currentUser.user.accessToken
                    }
                })
                .then(res => {
                    props.didLogout()
                })
                .catch(error => {
                    console.log(error)
                })
        }
    })

    return (
        <div>
            <Spinner animation="border" role="status">
                <span className="visually-hidden">Loading...</span>
            </Spinner>
        </div>
    )
}