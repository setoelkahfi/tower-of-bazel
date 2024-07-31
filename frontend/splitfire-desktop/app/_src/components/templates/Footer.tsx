import React from 'react'
import { Col, Row } from 'react-bootstrap'
import { Link } from 'react-router-dom'

const year = (new Date()).getFullYear();

export default function Footer() {
    return (
        <footer className="mt-5 text-white-50">
            <Row>
                <Col xs={6}>
                    <p className='float-start'>© {year}</p>
                </Col>
                <Col xs={6}>
                    <ul className="list-inline float-end">
                        <li className='list-inline-item'>
                            <Link to='/about' aria-current="page">About</Link>
                        </li>
                        <li className='list-inline-item'>
                            <Link to='/contact' aria-current="page">Contact</Link>
                        </li>
                    </ul>
                </Col>
            </Row>
        </footer>
    )
}