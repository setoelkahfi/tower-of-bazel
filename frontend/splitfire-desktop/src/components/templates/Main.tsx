import { Outlet, useLocation } from 'react-router-dom'
import Header from './Header'
import Footer from './Footer'

export default function Main() {

    const location = useLocation()

    return (
        <div className="main-container d-flex text-center text-white bg-dark">
            <div className="cover-container d-flex w-100 h-100 p-3 mx-auto flex-column">
                <main className="px-3 h-100">
                    <Header location={location} />
                    <div className="flex-wrapper">
                        <Outlet />
                        <Footer />
                    </div>
                </main>
            </div>
        </div>
    )
}