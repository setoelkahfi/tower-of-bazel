import { useState, useEffect } from 'react'
import { Spinner } from 'react-bootstrap'
import { FormattedMessage } from 'react-intl'
import { Navigate, Outlet, useOutletContext, useParams } from 'react-router-dom'
import { db, CurrentUserType, CurrentUser } from '../../lib/db'

type ContextType = { currentUser: CurrentUser };

export function useCurrentUser() {
    return useOutletContext<ContextType>()
}

export default function KaraokeView() {

    const { audioFileId } = useParams()
    const [currentUser, setCurrentUser] = useState<CurrentUser | undefined>(undefined)
    const [isRequesting, setisRequesting] = useState(true)


    useEffect(() => {
        db.currentUser.get({ type: CurrentUserType.MAIN }).then((res: CurrentUser | undefined ) => {
            if (res) {
                setCurrentUser(res)
            } else {
                setCurrentUser(undefined)
            }
            setisRequesting(false)
        }).catch( error => {
            //console.log(error)
            setCurrentUser(undefined)
            setisRequesting(false)
        }) 
    })
    
    if (isRequesting) {
        return <div>
            <p>
                <FormattedMessage id="home.loading"
                    defaultMessage="Loading SplitFire AI..."
                    description="Loading message" />
            </p>
            <Spinner animation='grow' variant="danger"></Spinner>
        </div>
    }

    if (!currentUser) {
        return <Navigate to={'/login'} />
    }

    if (currentUser && audioFileId) {
        return <Outlet context={{ currentUser }}/>
    }

    return <p>Something wrong</p>
}